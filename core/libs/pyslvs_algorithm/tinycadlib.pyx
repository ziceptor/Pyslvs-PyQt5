# -*- coding: utf-8 -*-
from libc.math cimport (
    pow,
    sqrt,
    isnan,
    sin,
    cos,
    atan2
)
from cpython cimport bool

nan = float("nan")

cdef class Coordinate(object):
    cdef public double x
    cdef public double y
    
    def __cinit__(self, double x, double y):
        self.x = x
        self.y = y
    
    cpdef double distance(self, Coordinate obj):
        return sqrt(pow(self.x-obj.x, 2) + pow(self.y-obj.y, 2))
    
    cpdef bool isnan(self):
        return isnan(self.x) or isnan(self.y)

cpdef object PLAP(Coordinate A, double L0, double a0, Coordinate B, bool inverse=False):
    cdef double b0 = atan2((B.y - A.y), (B.x - A.x))
    if inverse:
        return (A.x + L0*sin(b0 - a0), A.y + L0*cos(b0 - a0))
    else:
        return (A.x + L0*sin(b0 + a0), A.y + L0*cos(b0 + a0))

cpdef object PLLP(Coordinate A, double L0, double R0, Coordinate B, bool inverse=False):
    cdef double dx = B.x - A.x
    cdef double dy = B.y - A.y
    cdef double d = A.distance(B)
    #No solutions, the circles are separate.
    if d > L0 + R0:
        return (nan, nan)
    #No solutions because one circle is contained within the other.
    if d < abs(L0 - R0):
        return (nan, nan)
    #Circles are coincident and there are an infinite number of solutions.
    if d==0 and L0==R0:
        return (nan, nan)
    cdef double a = (pow(L0, 2) - pow(R0, 2) + pow(d, 2))/(2*d)
    cdef double h = sqrt(pow(L0, 2) - pow(a, 2))
    cdef double xm = A.x + a*dx/d
    cdef double ym = A.y + a*dy/d
    if inverse:
        return (xm + h*dy/d, ym - h*dx/d)
    else:
        return (xm - h*dy/d, ym + h*dx/d)

cpdef object PLPP(Coordinate A, double L0, Coordinate B, Coordinate C, bool inverse=False):
    cdef double x1 = A.x
    cdef double y1 = A.y
    cdef double x2 = B.x
    cdef double y2 = B.y
    cdef double x3 = C.x
    cdef double y3 = C.y
    if inverse:
        return (
            ((x2-x3)*(x1*x2*y2 - x1*x2*y3 - x1*y2*x3 + x1*x3*y3 + y1*y2**2 - 2*y1*y2*y3 + y1*y3**2 + x2**2*y3 - x2*y2*x3 - x2*x3*y3 + y2*x3**2 + (y2 - y3)*sqrt(L0**2*x2**2 - 2*L0**2*x2*x3 + L0**2*y2**2 - 2*L0**2*y2*y3 + L0**2*x3**2 + L0**2*y3**2 - x1**2*y2**2 + 2*x1**2*y2*y3 - x1**2*y3**2 + 2*x1*y1*x2*y2 - 2*x1*y1*x2*y3 - 2*x1*y1*y2*x3 + 2*x1*y1*x3*y3 - 2*x1*x2*y2*y3 + 2*x1*x2*y3**2 + 2*x1*y2**2*x3 - 2*x1*y2*x3*y3 - y1**2*x2**2 + 2*y1**2*x2*x3 - y1**2*x3**2 + 2*y1*x2**2*y3 - 2*y1*x2*y2*x3 - 2*y1*x2*x3*y3 + 2*y1*y2*x3**2 - x2**2*y3**2 + 2*x2*y2*x3*y3 - y2**2*x3**2)) - (x2*y3 - y2*x3)*(x2**2 - 2*x2*x3 + y2**2 - 2*y2*y3 + x3**2 + y3**2))/((y2 - y3)*(x2**2 - 2*x2*x3 + y2**2 - 2*y2*y3 + x3**2 + y3**2)),
            (x1*x2*y2 - x1*x2*y3 - x1*y2*x3 + x1*x3*y3 + y1*y2**2 - 2*y1*y2*y3 + y1*y3**2 + x2**2*y3 - x2*y2*x3 - x2*x3*y3 + y2*x3**2 + (y2 - y3)*sqrt(L0**2*x2**2 - 2*L0**2*x2*x3 + L0**2*y2**2 - 2*L0**2*y2*y3 + L0**2*x3**2 + L0**2*y3**2 - x1**2*y2**2 + 2*x1**2*y2*y3 - x1**2*y3**2 + 2*x1*y1*x2*y2 - 2*x1*y1*x2*y3 - 2*x1*y1*y2*x3 + 2*x1*y1*x3*y3 - 2*x1*x2*y2*y3 + 2*x1*x2*y3**2 + 2*x1*y2**2*x3 - 2*x1*y2*x3*y3 - y1**2*x2**2 + 2*y1**2*x2*x3 - y1**2*x3**2 + 2*y1*x2**2*y3 - 2*y1*x2*y2*x3 - 2*y1*x2*x3*y3 + 2*y1*y2*x3**2 - x2**2*y3**2 + 2*x2*y2*x3*y3 - y2**2*x3**2))/(x2**2 - 2*x2*x3 + y2**2 - 2*y2*y3 + x3**2 + y3**2)
        )
    else:
        return (
            ((x2-x3)*(x1*x2*y2 - x1*x2*y3 - x1*y2*x3 + x1*x3*y3 + y1*y2**2 - 2*y1*y2*y3 + y1*y3**2 + x2**2*y3 - x2*y2*x3 - x2*x3*y3 + y2*x3**2 + (-y2 + y3)*sqrt(L0**2*x2**2 - 2*L0**2*x2*x3 + L0**2*y2**2 - 2*L0**2*y2*y3 + L0**2*x3**2 + L0**2*y3**2 - x1**2*y2**2 + 2*x1**2*y2*y3 - x1**2*y3**2 + 2*x1*y1*x2*y2 - 2*x1*y1*x2*y3 - 2*x1*y1*y2*x3 + 2*x1*y1*x3*y3 - 2*x1*x2*y2*y3 + 2*x1*x2*y3**2 + 2*x1*y2**2*x3 - 2*x1*y2*x3*y3 - y1**2*x2**2 + 2*y1**2*x2*x3 - y1**2*x3**2 + 2*y1*x2**2*y3 - 2*y1*x2*y2*x3 - 2*y1*x2*x3*y3 + 2*y1*y2*x3**2 - x2**2*y3**2 + 2*x2*y2*x3*y3 - y2**2*x3**2)) - (x2*y3 - y2*x3)*(x2**2 - 2*x2*x3 + y2**2 - 2*y2*y3 + x3**2 + y3**2))/((y2 - y3)*(x2**2 - 2*x2*x3 + y2**2 - 2*y2*y3 + x3**2 + y3**2)),
            (x1*x2*y2 - x1*x2*y3 - x1*y2*x3 + x1*x3*y3 + y1*y2**2 - 2*y1*y2*y3 + y1*y3**2 + x2**2*y3 - x2*y2*x3 - x2*x3*y3 + y2*x3**2 + (-y2 + y3)*sqrt(L0**2*x2**2 - 2*L0**2*x2*x3 + L0**2*y2**2 - 2*L0**2*y2*y3 + L0**2*x3**2 + L0**2*y3**2 - x1**2*y2**2 + 2*x1**2*y2*y3 - x1**2*y3**2 + 2*x1*y1*x2*y2 - 2*x1*y1*x2*y3 - 2*x1*y1*y2*x3 + 2*x1*y1*x3*y3 - 2*x1*x2*y2*y3 + 2*x1*x2*y3**2 + 2*x1*y2**2*x3 - 2*x1*y2*x3*y3 - y1**2*x2**2 + 2*y1**2*x2*x3 - y1**2*x3**2 + 2*y1*x2**2*y3 - 2*y1*x2*y2*x3 - 2*y1*x2*x3*y3 + 2*y1*y2*x3**2 - x2**2*y3**2 + 2*x2*y2*x3*y3 - y2**2*x3**2))/(x2**2 - 2*x2*x3 + y2**2 - 2*y2*y3 + x3**2 + y3**2)
        )

cpdef bool legal_triangle(Coordinate A, Coordinate B, Coordinate C):
    #L0, L1, L2 is triangle
    cdef double L0 = A.distance(B)
    cdef double L1 = B.distance(C)
    cdef double L2 = A.distance(C)
    return L1+L2>L0 and L0+L2>L1 and L0+L1>L2

cpdef bool legal_crank(Coordinate A, Coordinate B, Coordinate C, Coordinate D):
    '''
    verify the fourbar is satisfied the Gruebler's Equation, s + g <= p + q
        C - D
        |   |
        A   B
    '''
    cdef double driver = A.distance(C)
    cdef double follower = B.distance(D)
    cdef double ground = A.distance(B)
    cdef double connector = C.distance(D)
    return (driver + connector <= ground + follower) or (driver + ground <= connector + follower)
