/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 1.3.39
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package org.doubango.tinyWRAP;

public enum twrap_media_type_t {
  twrap_media_none(0x00),
  twrap_media_audio(0x01),
  twrap_media_video(0x02),
  twrap_media_audiovideo(0x03),
  twrap_media_msrp(0x04);

  public final int swigValue() {
    return swigValue;
  }

  public static twrap_media_type_t swigToEnum(int swigValue) {
    twrap_media_type_t[] swigValues = twrap_media_type_t.class.getEnumConstants();
    if (swigValue < swigValues.length && swigValue >= 0 && swigValues[swigValue].swigValue == swigValue)
      return swigValues[swigValue];
    for (twrap_media_type_t swigEnum : swigValues)
      if (swigEnum.swigValue == swigValue)
        return swigEnum;
    throw new IllegalArgumentException("No enum " + twrap_media_type_t.class + " with value " + swigValue);
  }

  @SuppressWarnings("unused")
  private twrap_media_type_t() {
    this.swigValue = SwigNext.next++;
  }

  @SuppressWarnings("unused")
  private twrap_media_type_t(int swigValue) {
    this.swigValue = swigValue;
    SwigNext.next = swigValue+1;
  }

  @SuppressWarnings("unused")
  private twrap_media_type_t(twrap_media_type_t swigEnum) {
    this.swigValue = swigEnum.swigValue;
    SwigNext.next = this.swigValue+1;
  }

  private final int swigValue;

  private static class SwigNext {
    private static int next = 0;
  }
}

