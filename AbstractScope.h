#ifndef ABSTRACTSCOPE_H_
#define ABSTRACTSCOPE_H_
struct Token;
#include <string>
abstract class AbstractScope
{
 public:
  int installToken(struct Token *token);
  void upScope();
  std::string error_msg;
}
#endif
