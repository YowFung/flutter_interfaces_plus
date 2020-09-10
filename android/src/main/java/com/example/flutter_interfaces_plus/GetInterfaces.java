package com.example.flutter_interfaces_plus;

import android.annotation.TargetApi;
import android.os.Build;
import android.util.Log;

import java.net.InetAddress;
import java.net.InterfaceAddress;
import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.HashMap;


public class GetInterfaces {
  @TargetApi(Build.VERSION_CODES.GINGERBREAD)
  public static ArrayList<HashMap<String, String>> getInterfaceList() {
    ArrayList<HashMap<String, String>> resultList = new ArrayList<HashMap<String, String>>();

    try {
      Enumeration<NetworkInterface> eni = NetworkInterface.getNetworkInterfaces();
      while (eni.hasMoreElements()) {

        NetworkInterface networkCard = eni.nextElement();
        if (!networkCard.isUp())
          continue;

        String displayName = networkCard.getDisplayName();
        List<InterfaceAddress> addressList = networkCard.getInterfaceAddresses();
        Iterator<InterfaceAddress> addressIterator = addressList.iterator();

        while (addressIterator.hasNext()) {
          InterfaceAddress interfaceAddress = addressIterator.next();
          InetAddress address = interfaceAddress.getAddress();
          if (!address.isLoopbackAddress()) {
            String hostAddress = address.getHostAddress();

            if (hostAddress.indexOf(":") <= 0) {
              String maskAddress = calcMaskByPrefixLength(interfaceAddress.getNetworkPrefixLength());

              HashMap<String, String> tmpInterface = new HashMap<>();
              tmpInterface.put("name", displayName);
              tmpInterface.put("address", hostAddress);
              tmpInterface.put("mask", maskAddress);

              resultList.add(tmpInterface);
            }
          }
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
    }

    return resultList;
  }

  public static String calcMaskByPrefixLength(int length) {
    int mask = 0xffffffff << (32 - length);
    int partsNum = 4;
    int bitsOfPart = 8;
    int maskParts[] = new int[partsNum];
    int selector = 0x000000ff;

    for (int i = 0; i < maskParts.length; i++) {
      int pos = maskParts.length - 1 - i;
      maskParts[pos] = (mask >> (i * bitsOfPart)) & selector;
    }

    String result = "";
    result = result + maskParts[0];
    for (int i = 1; i < maskParts.length; i++)
      result = result + "." + maskParts[i];
    
    return result;
  }
}