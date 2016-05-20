%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdlib.h>
#include "MiniJava.tab.h"
#include "ClassInfo.h"
#include "Constant.h"
#include "FieldInfo.h"
#include "FieldType.h"
#include "MethodInfo.h"
#include <iostream>
  
  extern int yylex();
  void yyerror(const char*);


  void *scope;
  ClassInfo* root; //Pham vi hien tai dang xet

  enum TokenType
  {
    TK_VARIABLE, TK_CLASS, TK_METHOD,
    TK_IF, TK_ELSE, TK_SWITCH,
    TK_WHILE,
    TK_TYPE, TK_EXPRESSION, TK_CONSTANT
  };
  //Dung cho constant
  enum ConstantType
  {
    CONST_BOOLEAN,
    CONST_INT,
    CONST_FLOAT
  };

  struct Token
  {
    TokenType token_type;
    int line;
  
    //Nhung thong tin cho constant
    ConstantType const_type;
    char *const_value;

    //Nhung thong tin cho type
    FieldType::Type field_type;
    FieldType::BaseType base_type;
    std::string type_info;

    std::string name; //Dung cho ten ham, ten bien, ten class
    std::string params; //Dung cho ds tham so, ten class super
  };

  //Co the can luu token vao dslk de free khi can thiet
  struct Token* createToken(TokenType token_type)
  {
    struct Token *token = (struct Token*) malloc(sizeof(Token));
    token->token_type = token_type;
    token->line = yylloc.first_line;
    return token;
  }

  struct Token* createClassToken(std::string name, std::string super)
  {
    struct Token* token = createToken(TK_CLASS);
    token->name = name;
    token->params = super;
    return token;
  }

  struct Token* createVarToken(struct Token* type, std::string name)
  {
    struct Token* token = createToken(TK_VARIABLE);
    token->field_type = type->field_type;
    if (token->field_type == FieldType::BASE_TYPE)
      token->base_type = type->base_type;
    else
      token->type_info = type->type_info;
    token->name = name;
    return token;
  }
     
  struct Token* createTypeToken(FieldType::Type field_type, std::string info)
  {
    struct Token *token = createToken(TK_TYPE);
    token->field_type = field_type;
    if (field_type == FieldType::BASE_TYPE)
      {
	if (info == "BOOLEAN")
	  token->base_type = FieldType::BOOLEAN;
	else if (info == "INTEGER")
	  token->base_type = FieldType::INTEGER;
	else if (info == "FLOAT")
	  token->base_type = FieldType::FLOAT;
      }
    else
      token->type_info = info;
    return token;
  }


 
  void errorReport(const char* msg)
  {
    std::cout << "Error at line " << yylloc.first_line << ":" << msg << std::endl;
  }
 
  %}
/*------------------PART 2 ------------------*/
%union semrec {
  int num;
  float real;
  char* str;
  char* ident;
  struct Token* token;
}



%locations
%start Program
%token KW_CLASS KW_EXTENDS KW_PUBLIC KW_STATIC KW_BOOLEAN KW_STRING KW_FLOAT KW_INT
%token KW_IF KW_WHILE KW_BREAK KW_CONTINUE KW_SWITCH KW_CASE KW_DEFAULT KW_RETURN
%token KW_NEW KW_THIS KW_NULL KW_TRUE KW_FALSE KW_PRINTLN
%token IDENT INT_LITERAL FLOAT_LITERAL STRING_LITERAL TYPE_ERROR

%nonassoc "THEN"
%nonassoc KW_ELSE

%type <token> Type ClassDecl
%type <ident> IDENT ExtendsFrom

%right OP_ASSIGN
%left OP_OR
%left OP_AND
%nonassoc CMP_EQ CMP_NEQ
%nonassoc CMP_GT CMP_LT CMP_GTE CMP_LTE
%left OP_ADD OP_MINUS
%left OP_MULT OP_DIV OP_MOD
%right OP_NOT OP_UNARY
%left  '['  '.'
%nonassoc '('
%nonassoc ')'
%%



 /*---------------PART 3 -------------*/
Program:		ClassDeclp
;

ClassDeclp:		ClassDecl
| ClassDeclp ClassDecl
;

ClassDecl:		KW_CLASS IDENT ExtendsFrom {$$ =createClassToken(std::string($2), std::string($3));}
'{' VarDecls MethodDecls '}'
;

ExtendsFrom:		/*empty*/ {$$ = "Object";}
| KW_EXTENDS IDENT {$$ = yyval.ident;}
;

VarDecls:		VarDecls VarDecl 
| /*empty*/
;

VarDecl:		Type IDENT ';' {struct Token* token = createVarToken($1, std::string(yyval.ident));
 }
| KW_STATIC Type IDENT ';' /*Co the sua thanh AcessModifier Type IDENT*/
;

MethodDecls:		/*empty*/
| MethodDecls MethodDecl {printf("Method Decls\n");}
;

MethodDecl:		KW_PUBLIC Type MethodSignature
'{'VarDecls Statements KW_RETURN Expression ';' '}'
;

MethodSignature:	IDENT '('MethodParams')' 
;

MethodParams:		/*empty*/ 
| ListParam 
;

ListParam:		SingleParam
| SingleParam ',' ListParam
;

SingleParam:		Type IDENT
;

Type :			Type '['']' {$$=createTypeToken(FieldType::ARRAY_TYPE, "");}
| KW_BOOLEAN {$$=createTypeToken(FieldType::BASE_TYPE, std::string("BOOLEAN"));}
| KW_STRING {$$=createTypeToken(FieldType::OBJECT_TYPE, std::string("String"));}
| KW_FLOAT {$$=createTypeToken(FieldType::BASE_TYPE, std::string("FLOAT"));}
| KW_INT {$$=createTypeToken(FieldType::BASE_TYPE, std::string("INTEGER"));}
| IDENT {$$=createTypeToken(FieldType::OBJECT_TYPE, $1->name);}
;
Statements:		Statementp
| /*empty */
;
Statementp:		Statementp Statement
| Statement
;
Statement:		'{'Statements'}'
| KW_IF '(' Expression ')' Statement %prec "THEN" 
| KW_IF '(' Expression ')' Statement KW_ELSE Statement
| KW_WHILE '(' Expression ')'Statement
| KW_PRINTLN '(' Expression ')' ';'
| ArrayAccess OP_ASSIGN Expression ';'
| IDENT OP_ASSIGN Expression ';'     
| KW_BREAK ';'
| KW_CONTINUE ';'
| KW_SWITCH '(' Expression ')' '{'
Cases
KW_DEFAULT ':' Statementp '}'
;

Cases:		 	Cases Case
| /*empty*/
;
Case:		 	KW_CASE INT_LITERAL ':' Statementp
;


Expression:		Expression OP_OR Expression
| Expression OP_AND Expression
| Expression CMP_EQ Expression
| Expression CMP_NEQ Expression
| Expression CMP_GT Expression
| Expression CMP_GTE Expression
| Expression CMP_LT Expression
| Expression CMP_LTE Expression
| Expression OP_ADD Expression
| Expression OP_MINUS Expression
| Expression OP_MULT Expression
| Expression OP_DIV Expression
| Expression OP_MOD Expression
| '-' Expression %prec OP_UNARY
| OP_NOT Expression
| ArrayAccess
| LengthAccess
| Expression '.' Funcall
| INT_LITERAL
| FLOAT_LITERAL
| STRING_LITERAL
| KW_NULL
| KW_TRUE
| KW_FALSE
| IDENT
| KW_THIS
| KW_NEW Type '[' Expression ']'
| KW_NEW IDENT '('')'	    
| '(' Expression ')'
;

LengthAccess:		Expression '.'"length"
;
ArrayAccess:		IDENT '['Expression']'
;
Funcall:		IDENT '(' ParamList ')'
;
ParamList:		/*empty*/
| ParamList ',' Expression
| Expression
;
%%








int main(int argc, char** argv)
{
  extern FILE *yyin;
  ++argv; --argc;
  if (argc)
    yyin = fopen(argv[0], "r");
  else
    {
      printf("No input file\n");
      return 0;
    }

  root = new ClassInfo(1234);
  scope = root;
  yyparse();
  return 0;
}


void yyerror(const char *s)
{
  fprintf(stderr, "ERROR line %d: %s\n", yylloc.first_line,  s);
}
