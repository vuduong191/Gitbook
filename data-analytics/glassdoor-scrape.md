---
description: >-
  I worked with The Wonderful Company on a consulting project as part of our
  DSO_583: Operations Consulting class. Our team's task was to create an
  employer branding strategy for social media platforms.
---

# Scrape Glassdoor Reviews - Python

![Cover](../resources/P01/images/logo.png)

_This image may not relate to this project at all. All images, data and Python Codes can be found [here](https://github.com/vuduong191/Gitbook/tree/master/resources/P01)_

We felt the need to analyze the employee reviews on Glassdoor because it unlocks insights about current employees, so I wrote this python codes to scrape all reviews for The Wonderful Company and its competitors. I am not sure if this goes against the Glassdoor's terms of use, so please be conscious if you would like to do the same thing. 

Besides, this code works for the current layout and url structure of Glassdoor website. Any change or update to the website can render my codes useless, and you have to then adjust the code accordingly.

In this task, I used Beautiful Soup, a Python library for pulling data out of HTML and XML files.

## The structure of Glassdoor review pages and steps to scrape

**URL Structure**
```
https://www.glassdoor.com/Reviews/The-Wonderful-Company-Reviews-E1005987_P2.htm?sort.sortType=RD&sort.ascending=false
```
There're two thing we can observe from the url of a rating page
- There's an element that specifies page number in the url
- There're parameters for sorting (it's currently sorted by date from the newest to the oldest)

We will write code that go through pages and scrape all components we want

**Web Page Structure**

![Employee Review](../resources/P01/images/review.PNG)

This is how a review appears on the page. There're about 8 reviews a page. By inspecting the html codes, we see how different elements are wrapped. We use that insights to extract the right info:

Ex: Review summary is wrapped in a span tag with "summary" class. 
```html
<span class="summary ">"International opportunities"</span>
```
To grab all the tags with a given attribute value, we do this:
```python
Summary = soup.find_all('span', attrs = {'class':'summary'})
SummaryClean = []
for x in Summary:
    SummaryClean.append(x.text)
```
The review summaries are stored in a list. We use .text method to extract the text of a tag block.

Sometimes, the content we need does not exist as the text of any tag, but the value of an attribute. For example: overall rating, in this case 4.0/5 

```html
<span class="value-title" title="4.0"></span>
```
To grab the attribute values, instead of text, we do this:
```python
ValueTitle = soup.find_all('span', attrs = {'class':'value-title'})
ValueTitleClean = []
for x in ValueTitle:
    ValueTitleClean.append(x['title'])
```
**Unstructured elements**

Sometimes, the website allows some flexibility, which is our enemy. In this case, a user is allowed to rate any of five sub categories (Culture & Values, Work/Life Balance, Career Opportunities, Comp & Benefits, Senior Management). If we use above methods, we end up lists of different lengths, and we cannot merge these together to make a meaningful datatable. To get around this, at each iteration, we need to look for each of five category ratings and assign a none value if the user didn't rate for that.

After doing all of this, we have a clean table with these columns: 'Summary','Date', 'OverallRating', 'WorkLifeBalance', 'CultureValues', 'CareerOpportunities', 'CompBenefits', 'SeniorManagement', 'Pros', 'Cons'

Again, details can be found in the script. Happy scraping.