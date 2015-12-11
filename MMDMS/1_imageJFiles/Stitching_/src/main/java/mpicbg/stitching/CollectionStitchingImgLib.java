package mpicbg.stitching;

import ij.IJ;
import ij.gui.Roi;

import java.awt.Rectangle;
import java.util.ArrayList;
import java.util.Vector;
import java.util.concurrent.atomic.AtomicInteger;

import mpicbg.imglib.multithreading.SimpleMultiThreading;
import mpicbg.imglib.util.Util;
import mpicbg.models.TranslationModel2D;
import mpicbg.models.TranslationModel3D;

public class CollectionStitchingImgLib 
{

	public static ArrayList< ImagePlusTimePoint > stitchCollection( final ArrayList< ImageCollectionElement > elements, final StitchingParameters params)
	{
		// the result
		final ArrayList< ImagePlusTimePoint > optimized;
		
		if ( params.computeOverlap )
		{
			// find overlapping tiles
			final Vector< ComparePair > pairs = findOverlappingTiles( elements, params );
			
			if ( pairs == null || pairs.size() == 0 )
			{
				IJ.log( "No overlapping tiles could be found given the approximate layout." );
				return null;
			}
			
			// compute all compare pairs
			// compute all matchings
			final AtomicInteger ai = new AtomicInteger(0);
			
			final int numThreads;
			
			if ( params.cpuMemChoice == 0 )
				numThreads = 1;
			else
				numThreads = Runtime.getRuntime().availableProcessors();
			
	        final Thread[] threads = SimpleMultiThreading.newThreads( numThreads );
	    	
	        for ( int ithread = 0; ithread < threads.length; ++ithread )
	            threads[ ithread ] = new Thread(new Runnable()
	            {
	                public void run()
	                {		
	                   	final int myNumber = ai.getAndIncrement();
	                    
	                    for ( int i = 0; i < pairs.size(); i++ )
	                    {
	                    	if ( i % numThreads == myNumber )
	                    	{
	                    		final ComparePair pair = pairs.get( i );
	                    		
	                    		long start = System.currentTimeMillis();			
	                			
	                    		// where do we approximately overlap?
	                			final Roi roi1 = getROI( pair.getTile1().getElement(), pair.getTile2().getElement() );
	                			final Roi roi2 = getROI( pair.getTile2().getElement(), pair.getTile1().getElement() );
	                			
	            				final PairWiseStitchingResult result = PairWiseStitchingImgLib.stitchPairwise( pair.getImagePlus1(), pair.getImagePlus2(), roi1, roi2, pair.getTimePoint1(), pair.getTimePoint2(), params );			
	            				if ( result == null )
	            				{
	            					IJ.log( "Collection stitching failed" );
	            					return;
	            				}
	            				
	            				//added to fix error in phase corelation	            				
	            				float[] e1 = pair.getTile1().getElement().getOffset();
	            				float[] e2 = pair.getTile2().getElement().getOffset();
	            				
	            				float score = result.getCrossCorrelation();
	            				float erthres = (float)0.05;
	            				
	            				float dx=0, dy=0, dz=0;
	            				dx = Math.abs(Math.abs(e1[0]-e2[0]) - Math.abs(result.getOffset(0))) / pair.getTile1().getElement().getDimension(0);
	            				dy = Math.abs(Math.abs(e1[1]-e2[1]) - Math.abs(result.getOffset(1))) / pair.getTile1().getElement().getDimension(1);	            			
	            				
	            				if ( params.dimensionality == 3 )
	            				{
	            					dz = Math.abs(Math.abs(e1[2]-e2[2]) - Math.abs(result.getOffset(2))) / pair.getTile1().getElement().getDimension(2);
	            				}
	            				
	            				if ( params.dimensionality == 2 )
	            					pair.setRelativeShift( new float[]{ (dx > erthres || score < params.regThreshold) ? e2[0]-e1[0] : result.getOffset( 0 ), (dy > erthres || score < params.regThreshold) ? e2[1]-e1[1] : result.getOffset( 1 ) } );
	            				else
	            					pair.setRelativeShift( new float[]{ (dx > erthres || score < params.regThreshold) ? e2[0]-e1[0] : result.getOffset( 0 ), (dy > erthres || score < params.regThreshold) ? e2[1]-e1[1] : result.getOffset( 1 ), (dz > erthres || score < params.regThreshold) ? e2[2]-e1[2] : result.getOffset( 2 ) } );
	            				
	            				pair.setCrossCorrelation( (dx > erthres || dy > erthres || dz > erthres || score < params.regThreshold)? (float)params.regThreshold : result.getCrossCorrelation() );
	            				
	            				IJ.log( pair.getImagePlus1().getTitle() + "[" + pair.getTimePoint1() + "]" + " <- " + pair.getImagePlus2().getTitle() + "[" + pair.getTimePoint2() + "]" + ": " + 
	            						Util.printCoordinates( pair.getRelativeShift() ) + " correlation (R)=" + pair.getCrossCorrelation() + " (" + (System.currentTimeMillis() - start) + " ms)");
	
	            				
	                    	}
	                    }
	                }
	            });
	        
	        final long time = System.currentTimeMillis();
	        SimpleMultiThreading.startAndJoin( threads );
	        
	        // get the final positions of all tiles
	        
			optimized = GlobalOptimization.optimize( pairs, pairs.get( 0 ).getTile1(), params );
			IJ.log( "Finished registration process (" + (System.currentTimeMillis() - time) + " ms)." );
		}
		else
		{
			// all ImagePlusTimePoints, each of them needs its own model
			optimized = new ArrayList< ImagePlusTimePoint >();
			
			for ( final ImageCollectionElement element : elements )
			{
				final ImagePlusTimePoint imt = new ImagePlusTimePoint( element.open( params.virtual ), element.getIndex(), 1, element.getModel(), element );
				
				// set the models to the offset
				if ( params.dimensionality == 2 )
				{
					final TranslationModel2D model = (TranslationModel2D)imt.getModel();
					model.set( element.getOffset( 0 ), element.getOffset( 1 ) );
				}
				else
				{
					final TranslationModel3D model = (TranslationModel3D)imt.getModel();
					model.set( element.getOffset( 0 ), element.getOffset( 1 ), element.getOffset( 2 ) );					
				}
				
				optimized.add( imt );
			}
			
		}
		
		return optimized;
	}

	protected static Roi getROI( final ImageCollectionElement e1, final ImageCollectionElement e2 )
	{
		final int start[] = new int[ 2 ], end[] = new int[ 2 ];
		
		for ( int dim = 0; dim < 2; ++dim )
		{			
			// begin of 2 lies inside 1
			if ( e2.offset[ dim ] >= e1.offset[ dim ] && e2.offset[ dim ] <= e1.offset[ dim ] + e1.size[ dim ] )
			{
				start[ dim ] = Math.round( e2.offset[ dim ] - e1.offset[ dim ] );
				
				// end of 2 lies inside 1
				if ( e2.offset[ dim ] + e2.size[ dim ] <= e1.offset[ dim ] + e1.size[ dim ] )
					end[ dim ] = Math.round( e2.offset[ dim ] + e2.size[ dim ] - e1.offset[ dim ] );
				else
					end[ dim ] = Math.round( e1.size[ dim ] );
			}
			else if ( e2.offset[ dim ] + e2.size[ dim ] <= e1.offset[ dim ] + e1.size[ dim ] ) // end of 2 lies inside 1
			{
				start[ dim ] = 0;
				end[ dim ] = Math.round( e2.offset[ dim ] + e2.size[ dim ] - e1.offset[ dim ] );
			}
			else // if both outside then the whole image 
			{
				start[ dim ] = -1;
				end[ dim ] = -1;
			}
		}
		
		return new Roi( new Rectangle( start[ 0 ], start[ 1 ], end[ 0 ] - start[ 0 ], end[ 1 ] - start[ 1 ] ) );
	}

	protected static Vector< ComparePair > findOverlappingTiles( final ArrayList< ImageCollectionElement > elements, final StitchingParameters params )
	{		
		for ( final ImageCollectionElement element : elements )
		{
			if ( element.open( params.virtual ) == null )
				return null;
		}
		
		// all ImagePlusTimePoints, each of them needs its own model
		final ArrayList< ImagePlusTimePoint > listImp = new ArrayList< ImagePlusTimePoint >();
		for ( final ImageCollectionElement element : elements )
			listImp.add( new ImagePlusTimePoint( element.open( params.virtual ), element.getIndex(), 1, element.getModel(), element ) );
	
		// get the connecting tiles
		final Vector< ComparePair > overlappingTiles = new Vector< ComparePair >();
		
		// Added by John Lapage: if the sequential option has been chosen, pair up each image 
		// with the images within the specified range, and return.
		if ( params.sequential )
		{
			for ( int i = 0; i < elements.size(); i++ )
			{
				for ( int j = 1 ; j <= params.seqRange ; j++ )
				{
					if ( ( i + j ) >= elements.size() ) 
						break;
					
					overlappingTiles.add( new ComparePair( listImp.get( i ), listImp.get( i+j ) ) );
				}
			}
			return overlappingTiles;
		}
		// end of addition

		for ( int i = 0; i < elements.size() - 1; i++ )
			for ( int j = i + 1; j < elements.size(); j++ )
			{
				final ImageCollectionElement e1 = elements.get( i );
				final ImageCollectionElement e2 = elements.get( j );
				
				boolean overlapping = true;
				
				for ( int d = 0; d < params.dimensionality; ++d )
				{
					if ( !( ( e2.offset[ d ] >= e1.offset[ d ] && e2.offset[ d ] <= e1.offset[ d ] + e1.size[ d ] ) || 
						    ( e2.offset[ d ] + e2.size[ d ] >= e1.offset[ d ] && e2.offset[ d ] + e2.size[ d ] <= e1.offset[ d ] + e1.size[ d ] ) ||
						    ( e2.offset[ d ] <= e1.offset[ d ] && e2.offset[ d ] >= e1.offset[ d ] + e1.size[ d ] ) 
					   )  )
									overlapping = false;
				}
				
				if ( overlapping )
				{
					//final ImagePlusTimePoint impA = new ImagePlusTimePoint( e1.open(), e1.getIndex(), 1, e1.getModel().copy(), e1 );
					//final ImagePlusTimePoint impB = new ImagePlusTimePoint( e2.open(), e2.getIndex(), 1, e2.getModel().copy(), e2 );
					overlappingTiles.add( new ComparePair( listImp.get( i ), listImp.get( j ) ) );
				}
			}
		
		return overlappingTiles;
	}
}
