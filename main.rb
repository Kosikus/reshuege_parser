# Этот код необходим только при использовании русских букв на Windows
if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

# Подключаем
require 'net/http'

# путь к файлу со ссылками
urls_filepath = "#{__dir__}/data/urls.txt"

# все строки файла со ссылками
urls = File.readlines(urls_filepath, chomp: true, encoding: "utf-8")

# ссылки с удалёнными ненужными строками
urls.delete_if { |line| line.empty? ||  line.start_with?("#") }

# задачи на диске (текущие)
offline_problems = File.readlines("#{__dir__}/data/problems.txt", chomp: true, encoding: "utf-8")
offline_problems.delete("")

# задачи на сайте
remote_problems = []

urls.each_with_index do |url, index|
  url_page = Net::HTTP.get(
    URI.parse(URI.encode(url))
    ).force_encoding('UTF-8')

  remote_problems += url_page.scan(/(?<=problem\?id=)\d+(?=">)/)

  sleep(rand(4) + 3)

  puts index + 1
end

puts "offline_problems"
puts offline_problems.size

puts "remote_problems"
puts remote_problems.size

File.write("#{__dir__}/data/problems.txt", remote_problems.join("\n"), encoding: 'UTF-8')

date = Time.now
date_str = date.strftime("%d_%m_%Y_%Hh-%Mm-%Ss")

if (remote_problems - offline_problems).size.zero?
  report = 'Каталог упражение идентичен (изменений не произошло)'
else
  report = "Новые задачи: #{(remote_problems - offline_problems).join(", ")}\n" +
           "Удалённые задачи: #{(offline_problems - remote_problems).join(", ")}"
end

File.write("#{__dir__}/data/report_#{date_str}.txt", report, encoding: 'UTF-8')

puts "PARSING. OK!"
