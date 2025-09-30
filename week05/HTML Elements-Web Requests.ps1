<#
$scraped_page = Invoke-WebRequest -Uri "http://10.0.17.24/ToBeScraped.html"
# Get a count of the links in the page
$scraped_page.Links.Count

# Display links as HTML Element
$scraped_page.Links

# Display only URL and its text
$scraped_page.Links | Select-Object outerText, href

$h2s = $scraped_page.ParsedHtml.body.getElementsByTagName("h2")

$h2s | Select-Object outerText
#>

# Print innerText of every div element that has the class as "div-1"
$divs1 = $scraped_page.ParsedHtml.body.getElementsByTagName("div") | Where-Object {
    $_.getAttributeNode("class").Value -like "*div-1*"
} | Select-Object innerText
$divs1