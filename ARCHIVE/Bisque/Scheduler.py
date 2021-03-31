from Util.EmailClient import EmailClient
import fcntl, sys

if __name__ == "__main__":
	pid_file = 'program.pid'
	fp = open(pid_file, 'w')
	try:
    		fcntl.lockf(fp, fcntl.LOCK_EX | fcntl.LOCK_NB)
	except IOError:
    		print "Another instance is running"
    		sys.exit(0)
	


