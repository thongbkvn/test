#ifndef CONSTANT_H_
#define CONSTANT_H_
#include <string>

class Constant
{
  enum ConstantType {INT, FLOAT, STRING};
ConstantType type;
int int_val;
std::string string_val;
float float_val;
Constant(ConstantType type, int int_val);
Constant(ConstantType type, float float_val);
Constant(ConstantType type, std::string string_val);
};
#endif
