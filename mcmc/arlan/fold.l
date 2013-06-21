/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/*| Title:               Archetype Scanner                          |*/
/*| File Name:           arlan.l                                    |*/
/*| Owner:               Cortland D. Starrett                       |*/
/*|                                                                 |*/
/*| Abstract -                                                      |*/
/*|   This is the flex source file for the archetype action         |*/
/*|   language parser.                                              |*/
/*|                                                                 |*/
/*| Notes -                                                         |*/
/*|   By placing as much intelligence into the scanner as possible, |*/
/*|   the parser is much simpler and easier to build/maintain.  The |*/
/*|   cost to this approach is some loss of generality in the use   |*/
/*|   of special terms and key words.                               |*/
/*|   As it stands, the parser never needs to look at the text      |*/
/*|   from the input.  This is nice.                                |*/
/* _________________________________________________________________ */

%{

#include <string.h>
#include "y.tab.h"

extern char linestr[];
extern int i0, i1, line_number;
char * yylval;
/*-------------------------------------------------------------------*/
/* The following counter tells us when we are in a FOR statement.    */
/* A counter is used to support nesting.  The counter is zero (0)    */
/* when we are not in a for statement.                               */
/*-------------------------------------------------------------------*/
int forcnt = 0;
/*-------------------------------------------------------------------*/
/* The following stack lets us pop out into a previous state to      */
/* continue scanning in the previous state.  This is especially      */
/* handy for embedded strings and substitution variables.            */
/*-------------------------------------------------------------------*/
int current_state = INITIAL;    /* storage for current state         */
int saved_state[ 256 ];         /* stack for previous states         */
int stack_pointer = 0;
    
#define NSBEGIN(x)           stack_pointer = 0;                       \
                             saved_state[ stack_pointer ] = x;        \
                             current_state = x;                       \
                             BEGIN(x)
#define SBEGIN(x)            saved_state[ ++stack_pointer ] =         \
                             current_state;                           \
                             current_state = x;                       \
                             BEGIN(x)
#define SRETURN()            current_state =                          \
                             saved_state[ stack_pointer-- ];          \
                             BEGIN(current_state)
#define WHITE_RETURN(x)      strncat(linestr, yytext, yyleng);
#define CWHITE_RETURN(x)     strcat(linestr, " ");
#define F(x) {int i=yyleng; char *a=x; do {*a=tolower(*a);a++;} while(i-- > 0);}
#define CONTROL_RETURN(x)    NSBEGIN(control); F(yytext); RETURN_VAL(x)
#define ECONTROL_RETURN(x)   NSBEGIN(pc); F(yytext); RETURN_VAL(x)
#define KEYWORD_RETURN(x)    F(yytext); RETURN_VAL(x)
#define COMMENT_RETURN(x)    NSBEGIN(comment); RETURN_VAL(x)
#define WORD_RETURN(x)       RETURN_VAL(x)
#define OPERATOR_RETURN(x)   F(yytext); RETURN_VAL(x)
#define TYPE_RETURN(x)       F(yytext); RETURN_VAL(x)
#define TEXT_RETURN(x)       RETURN_VAL(x)
#define ASCIIOP_RETURN(x)    RETURN_VAL((int)*yytext)
#define NAMEDOP_RETURN(x)    RETURN_VAL(x)  /* multichar operator    */
#define NUMERICAL_RETURN(x)  RETURN_VAL(x)  /* some sort of constant */
#define LITERAL_RETURN(x)    NSBEGIN(literal); RETURN_VAL(x)
#define NEW_LINE_RETURN(x)   { int i;                                 \
                             line_number++;                           \
                             strncat(linestr, yytext, yyleng);        \
                             if ((current_state == control) ||        \
                                 (current_state == pc) ||             \
                                 (current_state == comment))          \
                               for(i=0;i<(2*i0);i++) putchar(' ');    \
                             printf("%s", linestr);                   \
                             linestr[0] = '\0';                       \
                             NSBEGIN(INITIAL);                        \
                             i0 = i1;                                 \
                             return(x); }
#define RETURN_VAL(x)        strncat(linestr, yytext, yyleng);        \
                             yylval = yytext;                         \
                             return(x);

%}

word          [a-zA-Z][0-9a-zA-Z_]*
exponent      [eE][-+]?[0-9]+
fraction      ([0-9]*"."[0-9]+)|([0-9]+".")
floater       (({fraction}{exponent}?)|([0-9]+{exponent}))[FfLl]?
dec_digits    [0-9]+
simple_escape [abfnrtv'"?\\]
octal_escape  [0-7]{1,3}
escape_seq    [\\]({simple_escape}|{octal_escape})
c_char        [^'\\\n]|{escape_seq}
h_tab         [\011]
h_white       [ ]|{h_tab}
dbl_dot       ".."
dbl_quote     "\"\""
dbl_dollar    "$$"

/*-------------------------------------------------------------------*/
/* Turn off the scan string function.  We will not use it.           */
/*-------------------------------------------------------------------*/
%option noyy_scan_string

/*-------------------------------------------------------------------*/
/* These ExCLUSIVE states effectively form three mini-scanners       */
/* separate from the main scanner.                                   */
/* pc and control are INCLUsIVE states.                              */
/* STATE       PURPOSE                                               */
/* comment     recognizes the internals of comments                  */
/* literal     parses literal text (output)                          */
/* rt          relationship traversal                                */
/* psv         pre-substitution variable (format)                    */
/* sv          substitution variable                                 */
/* pc          pre-control (start of line with control word)         */
/* control     control (action language instruction)                 */
/* str         string delimited by quotation marks                   */
/*-------------------------------------------------------------------*/
%x comment paramext literal rt psv
%s pc control str sv

%%

<<EOF>>                                 {return (0);}

<comment,literal,INITIAL,pc,control>"\n" {NEW_LINE_RETURN('\n');}

^{h_white}*/[^\.\n]                     {LITERAL_RETURN(LITERAL);}
^{h_white}*/{dbl_dot}                   {LITERAL_RETURN(LITERAL);}
<literal>[^$\n]*|{dbl_dollar}*          {TEXT_RETURN(TEXT);}
^{h_white}*/"."                         {
                                        NSBEGIN(pc);
                                        }
<control>{h_white}+                     {CWHITE_RETURN(' ');}
{h_white}+                              {WHITE_RETURN(' ');}
<paramext>{h_white}+                    {WHITE_RETURN(' ');}
<comment>"from instances of"|"FROM INSTANCES OF" {
                                        SBEGIN(paramext);
                                        KEYWORD_RETURN(FROMINSTOF);
                                        }
<paramext>{word}                        {SRETURN(); WORD_RETURN(WORD);}
<comment>[^ \n]*                        {TEXT_RETURN(TEXT);}
<comment>{h_white}+                     {WHITE_RETURN(' ');}

<pc>".//================="[=]*          {COMMENT_RETURN(CBLOCKDELIM);}
<pc>".//"                               {COMMENT_RETURN(COMMENT);}
<pc>".comment"|".COMMENT"               {COMMENT_RETURN(COMMENT);}
<pc>".function"|".FUNCTION"             {i0 = 0; i1 = 1;
                                         CONTROL_RETURN(FUNCTION);}
<pc>".param"|".PARAM"                   {CONTROL_RETURN(PARAM);}
<pc>".end function"|".END FUNCTION"     {i0 = 0; i1 = 0;
                                         ECONTROL_RETURN(ENDFUNCTION);}
<pc>".invoke"|".INVOKE"                 {CONTROL_RETURN(INVOKE);}
<pc>".clear"|".CLEAR"                   {CONTROL_RETURN(CLEARTOK);}
<pc>".select one"|".SELECT ONE"         {CONTROL_RETURN(SELECTONE);}
<pc>".select any"|".SELECT ANY"         {CONTROL_RETURN(SELECTANY);}
<pc>".select many"|".SELECT MANY"       {CONTROL_RETURN(SELECTMANY);}
<pc>".if"|".IF"                         {i1++; CONTROL_RETURN(IF);}
<pc>".elif"|".ELIF"                     {i0--; CONTROL_RETURN(ELIF);}
<pc>".else"|".ELSE"                     {i0--; CONTROL_RETURN(ELSE);}
<pc>".end if"|".END IF"                 {i0--; i1--; ECONTROL_RETURN(ENDIF);}
<pc>".for each"|".FOR EACH"             {i1++; forcnt++; CONTROL_RETURN(FOR);}
<pc>".break for"|".BREAK FOR"           {if (forcnt > 0) {
                                           ECONTROL_RETURN(BREAKFOR);
                                         } else
                                           yyerror(yytext);}
<pc>".end for"|".END FOR"               {i0--; i1--; forcnt--;
                                         ECONTROL_RETURN(ENDFOR);}
<pc>".while"|".WHILE"                   {i1++; CONTROL_RETURN(WHILE);}
<pc>".end while"|".END WHILE"           {i0--; i1--;
                                         ECONTROL_RETURN(ENDWHILE);}
<pc>".include"|".INCLUDE"               {CONTROL_RETURN(INCLUDE);}
<pc>".assign"|".ASSIGN"                 {CONTROL_RETURN(ASSIGN);}
<pc>".print"|".PRINT"                   {CONTROL_RETURN(PRINTTOK);}
<pc>".exit"|".EXIT"                     {CONTROL_RETURN(EXITTOK);}
<pc>".emit to file"|".EMIT TO FILE"     {CONTROL_RETURN(EMIT);}
<pc>".al_xlate"|".AL_XLATE"|"AL_xlate"  {CONTROL_RETURN(ALXLATE);}
<pc>"."{word}                           {WORD_RETURN(WORD);}
<control>"instance_sm"|"INSTANCE_SM"    {KEYWORD_RETURN(INSTANCESM);}
<control>"assigner_sm"|"ASSIGNER_SM"    {KEYWORD_RETURN(ASSIGNERSM);}
<control>"where"|"WHERE"                {KEYWORD_RETURN(WHERE);}
<control>"related by"|"RELATED BY"      {KEYWORD_RETURN(RELATEDBY);}
<control>"from instances of"|"FROM INSTANCES OF" {KEYWORD_RETURN(FROMINSTOF);}
<control>"in"|"IN"                      {KEYWORD_RETURN(IN);}
<control>"boolean"|"BOOLEAN"            {TYPE_RETURN(TYPE);}
<control>"integer"|"INTEGER"            {TYPE_RETURN(TYPE);}
<control>"real"|"REAL"                  {TYPE_RETURN(TYPE);}
<control>"string"|"STRING"              {TYPE_RETURN(TYPE);}
<control>"inst_ref"|"INST_REF"          {TYPE_RETURN(TYPE);}
<control>"inst_ref_set"|"INST_REF_SET"  {TYPE_RETURN(TYPE);}
<control>"frag_ref"|"FRAG_REF"          {TYPE_RETURN(TYPE);}
<control>"and"|"AND"                    {OPERATOR_RETURN(AND);}
<control>"or"|"OR"                      {OPERATOR_RETURN(OR);}
<control>"not"|"NOT"                    {OPERATOR_RETURN(UOP);}
<control>"empty"|"EMPTY"                {OPERATOR_RETURN(UOP);}
<control>"not_empty"|"NOT_EMPTY"        {OPERATOR_RETURN(UOP);}
<control>"first"|"FIRST"                {OPERATOR_RETURN(UOP);}
<control>"not_first"|"NOT_FIRST"        {OPERATOR_RETURN(UOP);}
<control>"last"|"LAST"                  {OPERATOR_RETURN(UOP);}
<control>"not_last"|"NOT_LAST"          {OPERATOR_RETURN(UOP);}
<control>"cardinality"|"CARDINALITY"    {OPERATOR_RETURN(UOP);}

<control>{dec_digits}         {NUMERICAL_RETURN(INTconstant);}
<control>{floater}            {NUMERICAL_RETURN(REALconstant);}
<control,str,sv>{word}        {WORD_RETURN(WORD);}


<control>["]                  {SBEGIN(str); ASCIIOP_RETURN('"');}
<str>[^ $\n"]*|{dbl_quote}*   {TEXT_RETURN(TEXT);}
<str>["]                      {SRETURN(); ASCIIOP_RETURN('"');}

<comment,literal>"$" {SBEGIN(psv); ASCIIOP_RETURN('$');}
"$"                  {SBEGIN(psv); ASCIIOP_RETURN('$');}
<psv>[UuCcLlRr_]*    {KEYWORD_RETURN(FORMAT);}
<psv>"{"             {SRETURN(); SBEGIN(sv); ASCIIOP_RETURN('{');}

<sv>"}"              {SRETURN(); ASCIIOP_RETURN('}');}

"["                  {SBEGIN(rt); ASCIIOP_RETURN('[');}
<rt>"R"{dec_digits}  {WORD_RETURN(RELTRANS);}
<rt>"."              {ASCIIOP_RETURN('.');}
<rt>"RI"|"IR"        {KEYWORD_RETURN(RELTRANS);}
<rt>"]"              {SRETURN(); ASCIIOP_RETURN(']');}

"."                  {ASCIIOP_RETURN('.');}
","                  {ASCIIOP_RETURN(',');}
"("                  {ASCIIOP_RETURN('(');}
")"                  {ASCIIOP_RETURN(')');}
"{"                  {ASCIIOP_RETURN('}');}
"}"                  {ASCIIOP_RETURN('}');}
"*"                  {ASCIIOP_RETURN('*');}
"+"                  {ASCIIOP_RETURN('+');}
"-"                  {ASCIIOP_RETURN('-');}
"/"                  {ASCIIOP_RETURN('/');}
"%"                  {ASCIIOP_RETURN('%');}
"<"                  {ASCIIOP_RETURN('<');}
">"                  {ASCIIOP_RETURN('>');}
":"                  {ASCIIOP_RETURN(':');}
";"                  {ASCIIOP_RETURN(';');}
"="                  {ASCIIOP_RETURN('=');}
"_"                  {ASCIIOP_RETURN('_');}

"->"                 {NAMEDOP_RETURN(ARROW);}
"<="                 {NAMEDOP_RETURN(LE);}
">="                 {NAMEDOP_RETURN(GE);}
"=="                 {NAMEDOP_RETURN(EQ);}
"!="                 {NAMEDOP_RETURN(NE);}

%%


/*
  Identity and Version Information -
  $Id: fold.l,v 1.1 2006/03/28 18:35:13 cstarret Exp $

  Revision History -
  $Log: fold.l,v $
  Revision 1.1  2006/03/28 18:35:13  cstarret
  Job:1865
  Adding arlan to CVS.
   ----------------------------------------------------------------------
   Added Files:
   	arlan.l arlan.y classes.l classes.y fold.l gen.l gen.y
   	makefile.arl makefile.arlan makefile.classes makefile.fol
   	makefile.fra makefile.fun makefile.gen makefile.ind
   	makefile.template template_engine.l template_engine.y
   ----------------------------------------------------------------------

 * Revision 1.3  1995/12/16  05:39:03  cort
 * Mostly changed to not have file name in main prologue.
 *
 * Revision 1.2  1995/11/27  02:57:02  cort
 * Latest folder and formatter.
 *
 * Revision 1.1  1995/11/17  03:27:42  cort
 * Supported formatting output (indenting).
 *
*/