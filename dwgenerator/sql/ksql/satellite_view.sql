--   ======================================================================================
--    AUTOGENERATED!!!! DO NOT EDIT!!!!
--   ======================================================================================

{% for source_table in mappings.source_tables(target_table) %}
{% set source_filter = mappings.filter(source_table, target_table) %}
{% set concat = joiner(" + '|' + ") %}

{% if loop.first %}
CREATE STREAM {{ target_table.schema }}__{{ target_table.name }}
AS
{% else %}
INSERT INTO {{ target_table.schema }}__{{ target_table.name }}
{% endif %}
SELECT
  {{ mappings.source_column(source_table, target_table.key) }} AS {{ target_table.key.name }}
  ,MD5({{ mappings.source_column(source_table, target_table.key) }}{{ concat() }}{% for attribute in target_table.attributes %}{{ concat() }} CAST({{ mappings.source_column(source_table, attribute) }} AS VARCHAR){% endfor %}) AS content
  {% for attribute in target_table.attributes %}
  ,{{ mappings.source_column(source_table, attribute) }} AS {{ attribute.name }}
  {% endfor %}
  ,{{ mappings.source_column(source_table, target_table.rec_src) }} AS {{ target_table.rec_src.name }}
FROM
  {{ source_table.schema }}__{{ source_table.name }}
{% if source_filter %}
WHERE
  {{ source_filter }}
{% endif %}
{% set concat = joiner(" + '|' + ") %}
PARTITION BY MD5({{ mappings.source_column(source_table, target_table.key) }}{{ concat() }}{% for attribute in target_table.attributes %}{{ concat() }} CAST({{ mappings.source_column(source_table, attribute) }} AS VARCHAR){% endfor %})
;
{% endfor %}