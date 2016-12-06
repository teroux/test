package com.ymagis.test.travis;

import org.junit.Assert;
import org.junit.Test;

public class LauncherTest {

    @Test
    public void test1() {
        System.out.println("test1");
        Assert.assertEquals(4, 4);
    }

    @Test
    public void test2() {
        System.out.println("test2");
        Assert.assertEquals(4, 4);
    }
}
