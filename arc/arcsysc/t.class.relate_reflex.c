.//============================================================================
.// Notice:
.// (C) Copyright 1998-2012 Mentor Graphics Corporation
.//     All rights reserved.
.//
.// This document contains confidential and proprietary information and
.// property of Mentor Graphics Corp.  No part of this document may be
.// reproduced without the express written permission of Mentor Graphics Corp.
.//============================================================================
.//
.if ( te_rel.LinkNeeded or te_c.OptDisabled )

/*
 * RELATE <left> ${te_class.Key_Lett} TO <right> ${te_class.Key_Lett} ACROSS R${te_rel.Numb}.'${rel_phrase}'
 */
void
${relate_method.result}( ${te_class.GeneratedName} * left, ${te_class.GeneratedName} * right${thismodule} )
{
  .if ( te_c.DetectEmpty )
  if ( (left == 0) || (right == 0) ) {
    XTUML_EMPTY_HANDLE_TRACE( "${te_class.Key_Lett}", "${relate_method.result}" );
    return;
  }
  .else
  /* Use TagEmptyHandleDetectionOn() to detect empty handle references.  */
  .end if
${set_referentials}\
  .if ( left_is_formalizer )
    .if ( part.Mult == 0 )
  left->${part_data_member.result} = right; /* SR L1 */
    .else
  ${te_set.module}${te_set.insert_element}( &left->${part_data_member.result}, right );
    .end if
    .if ( form.Mult == 0 )
  right->${form_data_member.result} = left; /* SR L2 */
    .else
  ${te_set.module}${te_set.insert_element}( &right->${form_data_member.result}, left );
    .end if
  .else
    .if ( part.Mult == 0 )
  right->${part_data_member.result} = left; /* SR L4 */
    .else
  ${te_set.module}${te_set.insert_element}( &right->${part_data_member.result}, left );
    .end if
    .if ( form.Mult == 0 )
  left->${form_data_member.result} = right; /* SR L5 */
    .else
  ${te_set.module}${te_set.insert_element}( &left->${form_data_member.result}, right );
    .end if
  .end if
${persist_relate.body}\
}
.else
/* Note:  R${te_rel.Numb}.'${rel_phrase}' never related (or not needed).  */
.end if

.if ( te_rel.UnlinkNeeded or te_c.OptDisabled )
/*
 * UNRELATE <left> ${te_class.Key_Lett} FROM <right> ${te_class.Key_Lett} ACROSS R${te_rel.Numb}.'${rel_phrase}'
 */
void
${unrelate_method.result}( ${te_class.GeneratedName} * left, ${te_class.GeneratedName} * right${thismodule} )
{
    .if ( te_c.DetectEmpty )
  if ( (left == 0) || (right == 0) ) {
    XTUML_EMPTY_HANDLE_TRACE( "${te_class.Key_Lett}", "${unrelate_method.result}" );
    return;
  }
    .else
  /* Use TagEmptyHandleDetectionOn() to detect empty handle references.  */
    .end if
${reset_referentials}\
    .if ( left_is_formalizer )
  left->${part_data_member.result} = 0; /* SR U1 */
      .if ( form.Mult == 0 )
  right->${form_data_member.result} = 0; /* SR U2 */
      .else
  ${te_set.module}${te_set.remove_element}( &right->${form_data_member.result}, left ); /* SR U3 */
      .end if
    .else
  right->${part_data_member.result} = 0; /* SR U4 */
      .if ( form.Mult == 0 )
  left->${form_data_member.result} = 0; /* SR U5 */
      .else
  ${te_set.module}${te_set.remove_element}( &left->${form_data_member.result}, right ); /* SR U6 */
      .end if
    .end if
${persist_unrelate.body}\
}
.else
/* Note:  R${te_rel.Numb}.'${rel_phrase}' never unrelated (or not needed).  */
.end if
.//