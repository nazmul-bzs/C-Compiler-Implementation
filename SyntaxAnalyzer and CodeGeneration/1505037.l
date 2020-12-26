
%x STRING_STATE
%x S_COMMENT_STATE
%x M_COMMENT_STATE

%option yylineno

%{
	#include<bits/stdc++.h>
	#include "1505037_symboltable.h"
	#include "y.tab.h"

	using namespace std;

	//extern YYSTYPE yylval;
	//extern SymbolTable *table;
	void yyerror(char *);

	int lineCount = 1;
	int errorCount = 0;
	
	string stringProcess = "";
	int stringInitLine = 0;

	string commentProcess = "";
	int commentInitLine = 0;
%}



WHITESPACE	[ \t\f\r\v]+

NEWLINE 	\n

ID		[a-zA-Z_][0-9a-zA-Z_]*
NUMBER		[0-9]

IS		{NUMBER}+{ID}+

CHAR		[ -~]{-}['\\]
CHARACTER	('({CHAR})')
SPECIAL_CHAR	'\\[ntafrbv0\"\\]'

MCE		('({CHAR}[^\n]+)')
UCE		('{CHAR}[^\n]*)

MSCE		'\\[^\n][^\n]+'
USCE		'[ntafrbv0\"\\]'

FLOAT		([0-9]+)?\.[0-9]+(E[+-]?[0-9]+)?

DPE		([0-9]+)?\.[0-9]*([\.]*[0-9]*)+(E[+-]?[0-9]+\.[0-9]*)?

IFN		([0-9]+)?\.[0-9]*([\.]*[0-9]*)+(E[+-]?[0-9]*\.[0-9]*)?




%%

{WHITESPACE}	{ /*do nothing*/ }


{NEWLINE}		{ lineCount++; }


"if"			{ return IF; }


"else" 			{ return ELSE; }


"for" 			{ return FOR; }


"while" 		{ return WHILE; }


"do"			{ return DO; }


"break"			{ return BREAK; }


"int" 			{ return INT; }


"char"			{ return CHAR; }


"float" 		{ return FLOAT; }


"double" 		{ return DOUBLE; }


"void" 			{ return VOID; }


"return"		{ return RETURN; }


"switch"		{ return SWITCH; }


"case"			{ return CASE; }


"default"		{ return DEFAULT; }


"continue"		{ return CONTINUE; }



"println"		{ return PRINTLN; }



"+"		|
"-"		{ SymbolInfo *s= new  SymbolInfo(yytext, "ADDOP");
		  yylval.sval = s;
		  return ADDOP; }



"*"		|
"/"		|
"%"		{ SymbolInfo *s = new  SymbolInfo(yytext, "MULOP");
		  yylval.sval = s;
		  return MULOP; }
		  
		  
"++"	|
"--"	{ SymbolInfo *s = new SymbolInfo(yytext, "INCOP");
		  yylval.sval = s;
		  return INCOP; }			  



">"		|
"<" 	|
">=" 	|
"<=" 	|
"==" 	|
"!=" 	{ SymbolInfo *s = new  SymbolInfo(yytext, "RELOP");
		  yylval.sval = s;
		  return RELOP; }

	
	
"=" 	{ return ASSIGNOP; }



"&&"	|
"||"	{ SymbolInfo *s = new  SymbolInfo(yytext, "LOGICOP");
		  yylval.sval = s;
		  return LOGICOP; }
		  
		  
"&"		|
"|"		|
"^"		|
"<<"	|
">>"	{ SymbolInfo *s = new SymbolInfo(yytext, "BITOP");
		  yylval.sval = s;
		  return BITOP; }
		  
		  
		  
"!"		{ return NOT; }



"(" 	{ return LPAREN; }



")" 	{ return RPAREN; }



"{" 	{ return LCURL; }



"}" 	{ return RCURL; }



"[" 	{ return LTHIRD; }



"]" 	{ return RTHIRD; }


"," 	{ return COMMA; }



";" 	{ return SEMICOLON; }




				  
				  
{SPECIAL_CHAR}	{ SymbolInfo *s= new  SymbolInfo(yytext, "CONST_CHAR");
				  yylval.sval = s;
				  return CONST_CHAR; }
				  
				  

{FLOAT}			{ SymbolInfo *s= new  SymbolInfo(yytext, "CONST_FLOAT", "FLOAT");
				  yylval.sval = s;
				  return CONST_FLOAT; }
				  
				  

"//"						{ BEGIN S_COMMENT_STATE;
		  					  commentProcess = "";
		  					  commentInitLine = lineCount; }

<S_COMMENT_STATE>[^\\\n]*	{ commentProcess += yytext; }

<S_COMMENT_STATE>"\\"		{ commentProcess += yytext; }

<S_COMMENT_STATE>"\\\n"		{ lineCount++; }

<S_COMMENT_STATE>"\n"		{ lineCount++;
				  			  //fprintf(logOut, "Line No. %d : Token <COMMENT> Lexeme %s found\n\n", commentInitLine, commentProcess.c_str());
				  			  BEGIN INITIAL; }



"/*"							{ BEGIN M_COMMENT_STATE;
		  						  commentProcess = "";
		  						  commentInitLine = lineCount; }

<M_COMMENT_STATE>[^"*"\n]*		{ commentProcess += yytext; }

<M_COMMENT_STATE>("*"[^/\n])*	{ commentProcess += yytext; }

<M_COMMENT_STATE>"*\n"			{ commentProcess += yytext;
				  				  lineCount++; }

<M_COMMENT_STATE>"\n"			{ lineCount++; }

<M_COMMENT_STATE>"*/"			{ //fprintf(logOut, "Line No. %d : Token <COMMENT> Lexeme %s found\n\n", commentInitLine, commentProcess.c_str());
				  				  BEGIN INITIAL; }

<M_COMMENT_STATE><<EOF>>		{ BEGIN INITIAL; }

				  
				  
{ID}			{ SymbolInfo *s= new  SymbolInfo(yytext, "ID");
				  yylval.sval = s;
				  return ID; }
				  
				  
				  
{NUMBER}+ 		{ SymbolInfo *s= new  SymbolInfo(yytext, "CONST_INT", "INT");
				  yylval.sval = s;
				  return CONST_INT; }
				  				  
%%

int yywrap(void)
{
	return 1;
}

