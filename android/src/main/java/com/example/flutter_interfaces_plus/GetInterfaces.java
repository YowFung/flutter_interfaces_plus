package com.example.flutter_interfaces_plus;

import android.annotation.TargetApi;
import android.os.Build;

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
  public static ArrayList<HashMap<String, Object>> getInterfaceList() {
    ArrayList<HashMap<String, Object>> root = new ArrayList<HashMap<String, Object>>();

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

        ArrayList<HashMap<String, Object>> addresses = new ArrayList<HashMap<String, Object>>();

        while (addressIterator.hasNext()) {
          InterfaceAddress interfaceAddress = addressIterator.next();
          int prefix = interfaceAddress.getNetworkPrefixLength();
          InetAddress address = interfaceAddress.getAddress();

          HashMap<String, Object> info = new HashMap<String, Object>();
          info.put("address", address != null ? address.getHostAddress() : "null");
          info.put("prefix", String.valueOf(prefix));

          addresses.add(info);
        }

        HashMap<String, Object> node = new HashMap<String, Object>();
        node.put("name", displayName);
        node.put("index", index);
        node.put("mac", mac);
        node.put("isVirtual", isVirtual);
        node.put("addresses", addresses);
        root.add(node);
      }
    } catch (Exception e) {
      e.printStackTrace();
    }

    return root;
  }
}