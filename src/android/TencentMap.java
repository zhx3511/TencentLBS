package com.example.loaction;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.map.geolocation.TencentLocation;
import com.tencent.map.geolocation.TencentLocationListener;
import com.tencent.map.geolocation.TencentLocationManager;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import permissions.RxPermissions;

public class TencentMap extends CordovaPlugin {
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("getTencentLocation")) {
            this.getTencentLocation(callbackContext);
            return true;
        }
        return false;
    }

    @SuppressLint("CheckResult")
    private void getTencentLocation(CallbackContext callbackContext) {
        new RxPermissions((Activity) this.webView.getContext()).request(Manifest.permission.ACCESS_FINE_LOCATION).subscribe(aBoolean -> {
            if (aBoolean) {
                TencentLocationManager mLocationManager = TencentLocationManager.getInstance(this.webView.getContext());
                mLocationManager.requestSingleFreshLocation(null, new TencentLocationListener() {
                    @Override
                    public void onLocationChanged(TencentLocation tencentLocation, int i, String s) {
                        if (!TextUtils.isEmpty(tencentLocation.getName()))
                            callbackContext.success(getTencentLocation(tencentLocation));
                        else
                            callbackContext.error("定位失败");
                    }

                    @Override
                    public void onStatusUpdate(String s, int i, String s1) {
                        callbackContext.error("定位失败");
                    }
                }, Looper.getMainLooper());
            } else {
            }
        });
    }

    private String getTencentLocation(TencentLocation tencentLocation) {
        JSONObject object = new JSONObject();
        try {
            object.put("latitude", tencentLocation.getLatitude());
            object.put("longitude", tencentLocation.getLongitude());
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return object.toString();

    }
}
