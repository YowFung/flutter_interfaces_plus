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

        while (addressIterator.hasNext()) {
          InterfaceAddress interfaceAddress = addressIterator.next();
          int prefix = interfaceAddress.getNetworkPrefixLength();
          InetAddress address = interfaceAddress.getAddress();

          JSONObject info = new JSONObject();
          info.put("address", address != null ? address.getHostAddress() : null);
          info.put("prefix", prefix);
          addresses.put(info);
        }

        JSONArray macArr = new JSONArray();
        if (mac != null) {
          for (int i = 0; i < mac.length; i++) {
            macArr.put(mac[i] & 0xFF);
          }
        }

        JSONObject node = new JSONObject();
        node.put("name", displayName);
        node.put("index", index);
        node.put("mac", macArr);
        node.put("isVirtual", isVirtual);
        node.put("addresses", addresses);
        root.put(node);
      }
    } catch (Exception e) {
      e.printStackTrace();
      Log.e("error", e.toString());
    }

    return root.toString();
  }
}