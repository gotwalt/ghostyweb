== Requirements

* Ruby 2.0.0-p353
* avahi redis sqlite3

= Avahi Configuration
```xml
<service-group>
  <name replace-wildcards="yes">Ghosty</name>
  <service>
    <type>_http._tcp</type>
    <port>80</port>
  </service>
</service-group>
```
