
function do_mysql() {
  mysql -hfrontend.cmqcwwja0pwe.us-east-1.rds.amazonaws.com -uwavii -phindered61spittoons7 rails_production_website --quick -B --skip-column-names --default-character-set=utf8 "$@" 
}

function row_count() {
  perl -e 'while(<STDIN>) {print}; END{ print STDERR "$ARGV[0]: $. Rows\n"; }' "$@"
}

function obfuscate() {
  ruby -e '
    require "./id_obfuscator"
    STDIN.each do |line|
      id = line.strip
      raise "Invalid non-numeric id '#{id}'" unless id == id.to_i.to_s
      puts Wavii::IdObfuscator.encode_id(id.to_i)
    end
  '
}

LIMIT=${LIMIT-"LIMIT 10"}
FROM_T='from slugs left join topics on (topics.cached_slug = slugs.name)'
do_mysql -e "select slugs.name                         $FROM_T where sluggable_type = 'Persistence::Topic' AND slugs.deleted_at IS NULL AND search_priority > 0 AND sequence = 1 $LIMIT;" | perl -pe 's#^#/topics/#' | row_count "Topics1"
do_mysql -e "select CONCAT(slugs.name, '--', sequence) $FROM_T where sluggable_type = 'Persistence::Topic' AND slugs.deleted_at IS NULL AND search_priority > 0 AND sequence != 1 $LIMIT;" | perl -pe 's#^#/topics/#' | row_count "Topics2"

do_mysql -e "select name                         from slugs where sluggable_type = 'User' AND deleted_at IS NULL AND sequence = 1 $LIMIT;" | perl -pe 's#^#/profile/#' | row_count "Users1"
do_mysql -e "select CONCAT(name, '--', sequence) from slugs where sluggable_type = 'User' AND deleted_at IS NULL AND sequence != 1 $LIMIT;" | perl -pe 's#^#/profile/#' | row_count "Users2"

do_mysql -e "select id from news_events where deleted_at IS NULL $LIMIT;" | obfuscate | perl -pe 's#^#/news/#' | row_count "NewsEvents"

do_mysql -e "select id from shares where deleted_at IS NULL $LIMIT;" | obfuscate | perl -pe 's#^#/share/#' | row_count "Shares"

