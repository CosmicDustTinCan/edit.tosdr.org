require 'json'
require 'pry'

# in repo root, run:
# rails runner db/import_points_from_old_db.rb

filepath_points = "old_db/points/"

def importPoint(data, service)
  puts 'old data:'
  puts data
  puts service
  puts 'new data:'
  serviceObjDefault = Service.find_by_name('amazon')
  serviceObj = Service.find_by_name(service) || serviceObjDefault
  puts serviceObj.id
  imported_point = Point.new(
    # old_id: data['id'] + '-' + service,
    title: data['title'],
    user_id: 3,
    source: "http://perdu.com",
    status: "pending",
    analysis: "Bla bla bla",
    rating: 3,
    topic_id: 31,
    service_id: serviceObj.id
  )

#  validates :title, presence: true
#  validates :title, length: { in: 5..140 }
#  validates :source, presence: true
#  validates :status, inclusion: { in: ["approved", "pending", "declined", "disputed", "draft"], allow_nil: false }
#  validates :analysis, presence: true
#  validates :rating, presence: true
#  validates :rating, numericality: true

  unless imported_point.valid?
    puts "### #{imported_point.title} not imported ! ###"
    # panic
  end
#    binding.pry
#    service_id: service.id,
#    topic = Topic.find_by_title(line['topics']) #need to import the services first and match it by string
#    topic_id: topic.id, #need to import topics first and match it by string
  imported_point.save
  puts 'saved.'
end

puts "Importing points..."
Dir.foreach(filepath_points) do |filename|
  next if filename == '.' or filename == '..' or filename == 'README.md'
  file = File.read(filepath_points + filename)
  data = JSON.parse(file)
  for i in 0 ... data['services'].size
    importPoint(data, data['services'][i])
  end
end
puts "Finishing importing points"
puts "Done!"
