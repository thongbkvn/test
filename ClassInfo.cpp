/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   ClassInfo.cpp
 * Author: thongbkvn
 * 
 * Created on May 18, 2016, 8:45 PM
 */

#include "ClassInfo.h"
#include "FieldType.h"
#include "MethodInfo.h"
#include <vector>
#include <string>

ClassInfo* ClassInfo::getClass(std::string class_name)
{
    if (this->name == class_name)
        return this;
    
    for (std::vector<ClassInfo*>::iterator i = this->childs.begin(); i != this->childs.end(); i++)
        return getClass(class_name);
    
    return NULL;
}


ClassInfo::ClassInfo(int object_code)
{
  if (object_code == 1234)
    {
      this->name = "Object";
      this->super = NULL;
      this->flags = ACC_PUBLIC;
      addMethod(new MethodInfo(FieldType(), "Object", MethodInfo::empty_param, this));
    }
}

//Gia su moi class tren cay ke thua deu khac ten
//Phai xac nhan kiem tra loi o ngoai, voi cai dat nay, neu khong tim thay super
//se dat super = root;
ClassInfo::ClassInfo(std::string name, std::string super_name, int flags)
{
    this->name = name;
    this->flags = flags;
    ClassInfo *sup;
    this->self = this;
    if (name == "Object")
      this->super = NULL;
    if (super != NULL)
      super->addChild(this);
}

int ClassInfo::addChild(ClassInfo *child)
{
  for (std::vector<ClassInfo*>::iterator i = childs.begin(); i != childs.end(); i++)
    if ((*i)->name == child->name)
      return 0;
    childs.push_back(child);
    return 1;
}

int ClassInfo::addDescendant(ClassInfo *descendant, std::string super_name)
{
  if (super_name == "")
    return addChild(descendant);
  
  ClassInfo *sup = getClass(super_name);
  if (sup != NULL)
    return sup->addChild(descendant);
  return 0;
}

int ClassInfo::addField(FieldInfo *field)
{
    if (field->name != this->name && getFieldLocal(field->name) == NULL && getMethodLocal(field->name) == NULL)
    {
        fields.push_back(field);
        return 1;
    }
    return 0;
}

FieldInfo* ClassInfo::getFieldLocal(std::string field_name)
{
    for (std::vector<FieldInfo*>::iterator i = fields.begin(); i != fields.end(); i++)
        if ((*i)->name == field_name)
            return *i;
    return NULL;
}

MethodInfo* ClassInfo::getMethodLocal(std::string method_name)
{
    for (std::vector<MethodInfo*>::iterator i = methods.begin(); i != methods.end(); i++)
        if ((*i)->name == method_name)
            return *i;
    return NULL;
}


int ClassInfo::addMethod(MethodInfo *method)
{
    if (method->name != this->name && getFieldLocal(method->name) == NULL && getMethodLocal(method->name) == NULL)
    {
        methods.push_back(method);
        return 1;
    }
    return 0;
}




 FieldInfo* getFieldInheirited(std::string field_name, ClassInfo *super)
 {
    if (super == NULL)
        return NULL;
    for (std::vector<FieldInfo*>::iterator i = super->fields.begin(); i != super->fields.end(); i++)
        if ((*i)->name == field_name && (((*i)->flags & FieldInfo::ACC_PUBLIC) || ((*i)->flags & FieldInfo::ACC_PROTECTED)))
            return *i;
    super = super->super;
    return getFieldInheirited(field_name, super);
 }

