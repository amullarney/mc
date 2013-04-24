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
 * RELATE ${part_te_class.Key_Lett} TO ${form_te_class.Key_Lett} ACROSS R${te_rel.Numb}
 */
void
${relate_method.result}( ${part_te_class.GeneratedName} * part, ${form_te_class.GeneratedName} * form${thismodule} )
{
  .if ( te_c.DetectEmpty )
  if ( (part == 0) || (form == 0) ) {
    XTUML_EMPTY_HANDLE_TRACE( "${form_te_class.Key_Lett}", "${relate_method.result}" );
    return;
  }
  .else
  /* Use TagEmptyHandleDetectionOn() to detect empty handle references.  */
  .end if
${set_referentials}\
  .if ( rto_NavigatedTo or te_c.OptDisabled )
    .if ( part.Mult == 0 )
  form->${form_data_member.result} = part;
    .else
  ${te_set.module}${te_set.insert_element}( &form->${form_data_member.result}, (${te_set.scope}${te_set.base_class} *) part );
    .end if
  .else
  /* Note:  ${form_te_class.Key_Lett}->${part_te_class.Key_Lett}[R${te_rel.Numb}] not navigated */
  .end if
  .if ( rgo_NavigatedTo or te_c.OptDisabled )
    .if ( form.Mult == 0 )
  part->${part_data_member.result} = form;
    .else
  ${te_set.module}${te_set.insert_element}( &part->${part_data_member.result}, (${te_set.scope}${te_set.base_class} *) form );
    .end if
  .else
  /* Note:  ${part_te_class.Key_Lett}->${form_te_class.Key_Lett}[R${te_rel.Numb}] not navigated */
  .end if
${persist_relate.body}\
}
.end if
.if ( te_rel.UnlinkNeeded or te_c.OptDisabled )

/*
 * UNRELATE ${part_te_class.Key_Lett} FROM ${form_te_class.Key_Lett} ACROSS R${te_rel.Numb}
 */
void
${unrelate_method.result}( ${part_te_class.GeneratedName} * part, ${form_te_class.GeneratedName} * form${thismodule} )
{
  .if ( te_c.DetectEmpty )
  if ( (part == 0) || (form == 0) ) {
    XTUML_EMPTY_HANDLE_TRACE( "${form_te_class.Key_Lett}", "${unrelate_method.result}" );
    return;
  }
  .else
  /* Use TagEmptyHandleDetectionOn() to detect empty handle references.  */
  .end if
${reset_referentials}\
  .if ( rto_NavigatedTo or te_c.OptDisabled )
    .if ( part.Mult == 0 )
  form->${form_data_member.result} = 0;
    .else
  ${te_set.module}${te_set.remove_element}( &form->${form_data_member.result}, (${te_set.scope}${te_set.base_class} *) part );
    .end if
  .else
  /* Note:  ${form_te_class.Key_Lett}->${part_te_class.Key_Lett}[R${te_rel.Numb}] not navigated */
  .end if
  .if ( rgo_NavigatedTo or te_c.OptDisabled )
    .if ( form.Mult == 0 )
  part->${part_data_member.result} = 0;
    .else
  ${te_set.module}${te_set.remove_element}( &part->${part_data_member.result}, (${te_set.scope}${te_set.base_class} *) form );
    .end if
  .else
  /* Note:  ${part_te_class.Key_Lett}->${form_te_class.Key_Lett}[R${te_rel.Numb}] not navigated */
  .end if
${persist_unrelate.body}\
}
.end if
.//