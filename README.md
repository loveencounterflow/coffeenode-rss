

# coffeenode-rss

RSS XML-blahfoo to liteweight JSON / HTML converter middleware

This software is probably not ready for general consumption, as it was built for a very specific purpose.

In your Express server's `app.coffee`, add a request handler like this:

````coffeescript
app.get '/vouchers/:tags?', ( request, response ) ->
  request_tags  = RSS.normalize_tags ( request.params[ 'tags' ] ? '' ).split ','
  url           = "https://gueltiger-gutschein.de/tag/#{request_tags.join ','}/feed"
  RSS.read url, ( error, rss ) =>
  	### `rss` now contains all entries with *any* of the tags; next we filter out all entries that are not
  	*not* marked with *all* of the tags specified in the request: ###
    rss = RSS.filter_for_tags rss, request_tags
    response.json rss
````

Here is what you could do on an HTML page to fetch the RSS and display its entries:

````coffeescript
$( document ).ready ->
	tags = 'berlin,vodafone'
	$.get "/vouchers/#{tags}", ( rss, status, jqXHR ) ->
		# if status isnt 'success'
		vouchers = []
		for entry in rss
			vouchers.push "<div class='entry'>#{entry[ 'content' ]}</div>"
		( $ '#vouchers' ).html vouchers.join '\n'
````
