require 'open-uri'
require 'nokogiri'
#require 'curb' #подключаем Curb если он есть
require 'csv'

# ПАРСЕР для http://www.petsonic.com/es/perros/snacks-y-huesos-perro

print "Введите Url страницы: "; url = gets.chomp

if url.reverse[0] == "/"
   url = url.chop     # отрезаем последний slash...если он есть
end


html = open(url)
#htnl = Curl.get(url) # тут должен был заработать Curb
doc = Nokogiri::HTML(html)
CSV.open("1.txt","w") do |wr|
	wr << ['название', 'количество', 'цена', 'картинка'] # подготавливаем файл для записи
end


quantity_str = doc.css('ul[class = "pagination pull-left"] li') # находим количество страниц для пагинации
int = quantity_str.size - 2
int_new = quantity_str[int]
print "Введите количество страниц max #{int_new.text.to_f.ceil}: "; page = gets.chomp

if page.to_f > int_new.text.to_f
	page =  int_new.text.to_f    # проверяем количество введенных страниц....если их больше чем реальных, то приравниваем
end


print "Введите полный путь к файлу для записи(Пример: D:/folder/folder/../your_file.csv): "; url_file = gets.chomp

CSV.open("#{url_file}","w") do |wr|
	wr << ['название', 'количество', 'цена', 'картинка'] # подготавливаем файл для записи
end



1.upto(page.to_f) do |i| # проходим циклом по страницам
	
	puts "Ждите, идет сбор информации со страницы номер #{i}..." # держим пользователя в курсе процесса
	new_url = "#{url}?p=#{i}"

	html = open(new_url)
	doc = Nokogiri::HTML(html)

	products = doc.css("a[class = 'product_img_link']").each do |product|	

		title = product['title'] # ищем название продукта

		images = product.css("img[class='replace-2x img-responsive']").each do |image|
			img = image['src'] # находим картинку

			html_new = open(product['href']) # переходим на вложенные странцы
			doc_new = Nokogiri::HTML(html_new)

			products_new = doc_new.css('ul[class="attribute_labels_lists"]').each do |product_new|
				price = product_new.css('span[class="attribute_price"]').text.strip # узнаем цену
				quantity = product_new.css('span[class="attribute_name"]').text # получем данные об упаковке (размер || вес)
				
				CSV.open("#{url_file}","a") do |wr|
					wr << [title, quantity, price, img]
				end
			end
		end	
	end	
end


str = open("#{url_file}").read.count("\n")
puts  "Готово!!!"
puts  "Данные записаны в файл #{url_file}" # даем финальный отчет о проделанной работе
puts  "Всего записано #{str} строк"

