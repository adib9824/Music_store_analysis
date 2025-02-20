-- Who is the senior-most employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Which country has the most invoices?
SELECT COUNT(billing_country) AS invoice_count, billing_country FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC
LIMIT 1;

-- What are the top 3 highest total invoice values?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Which city has the highest total sales?
SELECT billing_city, SUM(total) AS total_sales FROM invoice
GROUP BY billing_city
ORDER BY total_sales DESC
LIMIT 1;

-- Which customer has spent the most money?
SELECT customer.customer_id, customer.first_name, customer.last_name,
SUM(invoice.total) AS total_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- What is the total revenue generated for each music genre?
SELECT genre.name,
SUM(invoice_line.unit_price * invoice_line.quantity) AS total_revenue
FROM genre
JOIN track ON track.genre_id = genre.genre_id
JOIN invoice_line ON track.track_id = invoice_line.track_id
GROUP BY genre.name
ORDER BY total_revenue DESC;

-- Who are the top 5 customers who have spent the most money?
SELECT customer.first_name, customer.last_name,
SUM(invoice.total) AS total_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.first_name, customer.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- How many tracks are there in each playlist?
SELECT playlist.name AS playlist_name, COUNT(playlist_track.track_id) AS track_count
FROM playlist
JOIN playlist_track ON playlist.playlist_id = playlist_track.playlist_id
GROUP BY playlist.name
ORDER BY track_count DESC;

-- Which customers have purchased Rock genre tracks?
SELECT email, first_name, last_name FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
    SELECT track_id FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

-- Who are the top 10 artists with the most Rock genre songs?
SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS num_of_songs
FROM track
JOIN album ON track.album_id = album.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY num_of_songs DESC
LIMIT 10;

-- Which songs are longer than the average song length?
SELECT name, milliseconds AS song_length
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) FROM track
)
ORDER BY song_length DESC;

-- Find the customers who purchased tracks from the best-selling artist
WITH best_selling_artist AS (
    SELECT artist.artist_id, artist.name AS artist_name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    INNER JOIN track ON track.track_id = invoice_line.track_id
    INNER JOIN album ON album.album_id = track.album_id
    INNER JOIN artist ON album.artist_id = artist.artist_id
    GROUP BY artist.artist_id
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT customer.customer_id, customer.first_name, customer.last_name,
best_selling_artist.artist_name,
SUM(invoice_line.unit_price * invoice_line.quantity) AS total_spent
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN best_selling_artist ON best_selling_artist.artist_id = album.artist_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name
ORDER BY total_spent DESC;
