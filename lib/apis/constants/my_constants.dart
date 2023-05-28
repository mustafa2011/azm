class MyConstant {
  static const url =
      "https://script.google.com/macros/s/AKfycbzY_G9ci09GUWiUxiNeTSXvoyLPoSanEoyakxg07NivcuzRrY1hgkaoNpknhwHVLu91Lg/exec";
  static const credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheets-317608",
  "private_key_id": "6fbf83b277f2e2e8a0a2f8c0674eefb76883f0d3",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDPwPlY/ljRkKOh\n5Oya7Ce/VJJgX7Gl5PWMwnKOvz4ym6Wr23jpt4ebdLLxrezWwrz0WbxSCogcyVZO\nDRUFDf8RsuukCrRLEtuABslHdj4kTzQ/X6NVRU8kTpnWMcAUfuH/KLk0PE25ro1H\nH6Jnxa3Om1MlprGorvfg0vwhnZ7DzEiFhi7kz7/kvRVWdn7AONZbblMjooeARxYn\n3smleIWSEh/Z0bUU+PMfOvwVtfbJEZyR62A2+CnokkVbHR+pZRD3DwT3gUzISQOg\nwNRtPig1P/hOf8oTa5BoxoHso7eRAEN2N1yewsdfDuAXOa28Jtt3ky/+iT3UpVTm\n3W7BmgWnAgMBAAECggEACcEzVADj9bm3XSzNCTx+ZJxEH99OYuOHE1wL70o+fDd/\nsLvmMlR05bvggmWFYdNp9i/XyPhdShC6tdZ6aVmDY6GFhpcevl79IcaadnmwUu8f\nHRH7WXp0IVh0Hluz+6Jg2noJ3CXatmsM5M0w8x4T2kgZFYL9WNYXpchHoLfFvRwJ\nlEGDk3kWldJ8qeG/1mAxxTvXaR0qNX5yMjkN/XXKIJCcCODZ44GMZzGjHsJhW1iv\neHdJSB15FzufBEuPxGR0tI0h3vlhys+cRR5faKkC8pwm/n82xv7uhtEJdaGorudy\n3r66EA16TbcESfvug/PXgwYTwfK7vt+4Q2Vr0xr2mQKBgQDtzFg9jk+5roD6tCat\nQeqJQ/9naaOoFwExKEl7UdpmcNzMbqEqdYMhpqjJ2gR/SxE8Jsyz62KwRckwcIE7\nJ79w1q5S13Jr4HgGFUWTi8a2u+KOj2GZ/E+SSvgLA2I4PXzGHn/iuVJuWZgU8TlF\nQpN0wIsv0Lda90Z/ia6AfH8PiQKBgQDfp+i51clFbrQHTW8byd7dgeXOWV/AlrYi\nZRmUY1wLfoulBMKieD1hCus2+9sqLDuR8pCntsVyXfeGQrRKcy41A6z2gFjpkb88\nWcZ/5aID9CZp329juNkBlwOWmAWAqns7DJI1J72a0z54pfLVcK+bVQWiTpW/u/wr\nJAAPhHJvrwKBgQDaXE6bF9c11nwxusPZTTIlIf+h4muZqqY5kZkIWL2IXBMk1mHA\nL3Besj9EO6LtkO0eozJN9NQGsc5xYJ4KyBEPeNNS1uwHC3SrgVUGi8/JdPYxmpAx\nanNXDuh+lHjY0/2Dn/YnJ63+Dt+MO4Yvh1cIWtZ07d+w9GgULUXETo4OoQKBgHT+\nNmUPieuCDzZKsTZOEQC59GZOpiHuNHQlgo32s61nktDNfqrSTvk2ZvgqIukankao\nJjc1Cm/a66IVvo27Vo5wz8daOChmDy0YoRdCHdAHpRh4wqHdjdahEkVyXF6Dz1aC\nKvEXSr10hxdBZ5dzDMkqXnoatYbIZQ6EFGwJknsNAoGAUnj8o2ekM/GB3Xn0DGNq\ni+qn9gSF69pRl4/m7q1SjYDiJ+DrxxurkGmtnVcK/yOVwau+IiEAmQk4mpwnWKdt\nqQSNpMFKJThSeGbwnY8EyIQus47tDMFtmiu8SLesIws/lITmBg2X8T2DaL+BeBg+\niuvzFXGmUjqtNWmMjhIRUe0=\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@gsheets-317608.iam.gserviceaccount.com",
  "client_id": "111474211196308320107",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gsheets-317608.iam.gserviceaccount.com"
}
''';

  //To retrieve 'mySheetId' later from ClientSheetId
  static const mySheetId = '1uA1Yib05DypFgGnv6r77KoqRwgbP3r9Oz1uXy_NpQG4';

  //The following sheet id including the app clients information
  static const clientSheetId = '1F_z-MfbkznwSqoc2jH7mps1Dn-bhAUjtL7ek5T-eDgQ';
}
