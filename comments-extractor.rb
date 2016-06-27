require 'watir-webdriver'
require 'csv'

# b = Watir::Browser.new :phantomjs
b = Watir::Browser.new :firefox

b.window.maximize
begin
  b.goto 'https://play.google.com/store/apps/details?id=com.pontomobi.farm'
  puts ">> #{b.title}"

  next_button = b.buttons(class: 'expand-next')[1]
  next_button.click

  h1_resenha = b.div(class: 'details-section-heading').h1(class: 'heading')
  container = h1_resenha.parent.parent
  counter = 0
  CSV.open('extracted-reviews.csv', 'wb', { col_sep: ';' }) do |csv|
    while next_button.visible?
      puts '>> Parsing page'

      reviews_dates = container.elements(class: 'review-date')
      puts reviews_dates.size

      reviews_dates.each do |review_date|
        review = review_date.parent.parent.parent
        next if review.span(:class, 'author-name').a.text.empty?
        author = review.span(:class, 'author-name').a.text
        date = review_date.text
        review = review.div(:class, 'review-body').text
        puts "#{counter+=1} #{author},#{date}, #{review}"
        csv << [author, date, review]
      end
      puts '>> Clicking next'
      next_button.click
      sleep 10
    end

    puts '>> Button next not visible. End of script!'
  end

  b.close
rescue Exception => e
  puts e.backtrace
  b.close
  puts e
end
