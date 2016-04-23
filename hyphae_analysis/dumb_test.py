__author__ = 'rhein'


class C(object):
    def __new__(cls, *args, **kwargs):
        self = super(C, cls).__new__(cls, *args, **kwargs)
        raise Exception
        self.v = 'v'
        return self

    def __del__(self):
        print 'del', self.v


c = C()
