#include "ErrorReport.h"
   void errorReport(ErrorType type, int line)
    {
        std::string msg;
        switch (type)
        {
            case SAME_TYPE:
                msg = "Expressions must have the same type at line " + line;
                break;
            case BOOL_EXP:
                msg = "Expression type must have boolean type at line " + line;
        }
        std::cout << msg << std::endl;
    }
