--   ======================================================================================
--    AUTOGENERATED!!!! DO NOT EDIT!!!!
--   ======================================================================================

{% for source_table in mappings.source_tables(target_table) %}
{% set source_filter = mappings.filter(source_table, target_table) %}

{% if loop.first %}
CREATE STREAM {{ target_table.schema }}__{{ target_table.name }}
AS
{% else %}
INSERT INTO {{ target_table.schema }}__{{ target_table.name }}
{% endif %}
{% set concat = joiner(" + '|' + ") %}
SELECT
  {%+ for key in target_table.keys %}{{ concat() }}CAST({{ mappings.source_column(source_table, key) }} AS VARCHAR){% endfor %} AS {{ target_table.root_key.name }}
  {% for key in target_table.keys %}
  ,CAST({{ mappings.source_column(source_table, key) }} AS VARCHAR) AS {{ key.name }}
  {% endfor %}
  ,{{ mappings.source_column(source_table, target_table.rec_src) }} AS {{ target_table.rec_src.name }}
FROM {{ source_table.schema }}__{{ source_table.name }}
{% if source_filter %}
WHERE {{ source_filter }}
{% endif %}
{% set concat = joiner(" + '|' + ") %}
PARTITION BY MD5({%+ for key in target_table.keys %}{{ concat() }}CAST({{ mappings.source_column(source_table, key) }} AS VARCHAR){% endfor %})
;
{% endfor %}