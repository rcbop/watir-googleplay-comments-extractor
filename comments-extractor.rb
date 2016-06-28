require 'watir-webdriver'
require 'csv'

b = Watir::Browser.new :phantomjs
# b = Watir::Browser.new :firefox

app_id = ARGV[0]

b.window.maximize
begin
  b.goto "https://play.google.com/store/apps/details?id=#{app_id}"
  puts ">> #{b.title}"

  next_button = b.buttons(class: 'expand-next')[1]
  next_button.click

  h1_review = b.div(class: 'details-section-heading').h1(class: 'heading')
  container = h1_review.parent.parent
  counter = 0

  output_filename = 'extracted-reviews.csv'
  File.delete output_filename if File.exists? output_filename

  CSV.open(output_filename, 'wb', { col_sep: ';' }) do |csv|
    while next_button.visible?
      puts '>> extracting comments'

      reviews = container.elements(class: 'single-review').select {|div| div.visible?}
      puts "reviews found #{reviews.size}"

      reviews.each do |rev|
        next if rev.span(:class, 'author-name').text.empty?
        author = rev.span(:class, 'author-name').text
        date = rev.span(:class, 'review-date').text
        review = rev.div(:class, 'review-body').text
        puts "#{counter+=1} #{author},#{date}, #{review}"
        csv << [author, date, review]
      end
      puts '>> Clicking next'
      next_button.click
      sleep 2
    end

    puts '>> Button next not visible. End of script!'
  end
  b.close
rescue Exception => e
  puts e
end
