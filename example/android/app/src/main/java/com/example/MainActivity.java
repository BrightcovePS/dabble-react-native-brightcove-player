package com.example;

import jp.manse.BrightcoveReactActivity;

public class MainActivity extends BrightcoveReactActivity {

  /**
   * Returns the name of the main component registered from JavaScript. This is used to schedule
   * rendering of the component.
   */
  @Override
  protected String getMainComponentName() {
    return "example";
  }
}
