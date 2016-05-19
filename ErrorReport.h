/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   ErrorReport.h
 * Author: thongbkvn
 *
 * Created on May 19, 2016, 12:26 AM
 */

#ifndef ERRORREPORT_H_
#define ERRORREPORT_H_
#include <iostream>
#include <string>
    enum ErrorType {SAME_TYPE, BOOL_EXP};
    void errorReport(ErrorType type, int line);

#endif /* ERRORREPORT_H */

