package com.example.flutter_interfaces_plus;

import android.annotation.TargetApi;
import android.os.Build;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.net.InetAddress;
import java.net.InterfaceAddress;
import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;


public class GetInterfaces {
  @TargetApi(Build.VERSION_CODES.GINGERBREAD)
  public static String getInterfaceList() {
    JSONArray root = new JSONArray();

    try {
      Enumeration<NetworkInterface> eni = NetworkInterface.getNetworkInterfaces();
      int cardCounter = 0;

      while (eni.hasMoreElements()) {

        NetworkInterface networkCard = eni.nextElement();
        if (!networkCard.isUp())
          continue;

        String displayName = networkCard.getDisplayName();
        int index = networkCard.getIndex();
        boolean isVirtual = networkCard.isVirtual();
        byte[] mac = networkCard.getHardwareAddress();

        List<InterfaceAddress> addressList = networkCard.getInterfaceAddresses();
        Iterator<InterfaceAddress> addressIterator = addressList.iterator();

        JSONArray addresses = new JSONArray();
        int addressCounter = 0;

        while (addressIterator.hasNext()) {
          InterfaceAddress interfaceAddress = addressIterator.next();
          int prefix = interfaceAddress.getNetworkPrefixLength();
          InetAddress address = interfaceAddress.getAddress();

          JSONObject info = new JSONObject();
          info.put("address", address != null ? address.getHostAddress() : "null");
          info.put("prefix", String.valueOf(prefix));

          addresses.put(addressCounter++, info);
        }

        JSONObject node = new JSONObject();
        node.put("name", displayName);
        node.put("index", index);
        node.put("mac", mac);
        node.put("isVirtual", isVirtual);
        node.put("addresses", addresses);
        root.put(cardCounter++, node);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }

    Log.e("JSON", root.toString());
    return root.toString();
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