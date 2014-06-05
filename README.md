## Requirements

* Ruby 2.0.0-p353
* redis libsqlite3-dev

## Delivery Version
* avahi

### Avahi Configuration
```xml
<service-group>
  <name replace-wildcards="yes">Ghosty</name>
  <service>
    <type>_http._tcp</type>
    <port>80</port>
  </service>
</service-group>
```
