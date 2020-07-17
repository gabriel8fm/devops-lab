# Manages the php-fpm main ini file
{% from 'php/map.jinja' import php with context %}
{% from 'php/map.jinja' import fpm with context %}
{% from "php/ini.jinja" import php_ini %}

{% set ini_settings = php.ini.defaults %}
{% for key, value in php.fpm.config.ini.settings.iteritems() %}
  {% if ini_settings[key] is defined %}
    {% do ini_settings[key].update(value) %}
  {% else %}
    {% do ini_settings.update({key: value}) %}
  {% endif %}
{% endfor %}

{% set conf_settings = php.lookup.fpm.defaults %}
{% do conf_settings.update(php.fpm.config.conf.settings) %}

php_fpm_ini_config:
  {{ php_ini(php.lookup.fpm.ini, php.fpm.config.ini.opts, ini_settings) }}

php_fpm_conf_config:
  {{ php_ini(php.lookup.fpm.conf, php.fpm.config.conf.opts, conf_settings) }}

php_fpm_reload:
  cmd.run:
    - name: ls /etc/init.d/ | grep fpm | xargs -i service {} reload
    - onchanges:
      - file: php_fpm_ini_config
      - file: php_fpm_conf_config
