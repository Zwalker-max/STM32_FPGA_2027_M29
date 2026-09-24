#include "bsp_complex.h"

Complex add_com(Complex a, Complex b)
{
    Complex res;
    res.real = a.real + b.real;
    res.imag = a.imag + b.imag;
    return res;
}


Complex sub_com(Complex a, Complex b)
{
    Complex res;
    res.real = a.real - b.real;
    res.imag = a.imag - b.imag;
    return res;
}

Complex mul_com(Complex a, Complex b)
{
    Complex res;
    res.real = a.real * b.real - a.imag * b.imag;
    res.imag = a.real * b.imag + a.imag * b.real;
    return res;
}

Complex div_com(Complex a, Complex b)
{
    Complex res;
    float denom = b.real * b.real + b.imag * b.imag;
    res.real = (a.real * b.real + a.imag * b.imag) / denom;
    res.imag = (a.imag * b.real - a.real * b.imag) / denom;
    return res;
}
