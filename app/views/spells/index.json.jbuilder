json.array!(@spells) do |spell|
  json.extract! spell, :id, :name, :level, :school, :casting_time, :range, :duration, :description
  json.url spell_url(spell, format: :json)
end
