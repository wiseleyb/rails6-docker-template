# Notes  

Based on articles:
* https://evilmartians.com/chronicles/graphql-on-rails-1-from-zero-to-the-first-query
* https://www.keypup.io/blog/graphql-the-rails-way-part-1-exposing-your-resources-for-querying

# Example

```
{
  testField
  me {
    name
    articles {
      edges {
        node {
          title
        }
      }
    }
  }
  articles {
    edges {
      node {
        title
      }
    }
  }
  users {
    edges {
      node {
        name
         articles {
          edges {
            node {
              title
            }
          }
        }
      }
    }
  }
}
```
