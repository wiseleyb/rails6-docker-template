# Notes  

Based on articles:
* https://evilmartians.com/chronicles/graphql-on-rails-1-from-zero-to-the-first-query
* https://www.keypup.io/blog/graphql-the-rails-way-part-1-exposing-your-resources-for-querying
* https://www.keypup.io/blog/graphql-the-rails-way-part-2-writing-standard-and-custom-mutations
* https://www.keypup.io/blog/graphql-the-rails-way-part-3-subscriptions-with-websockets-via-pusher
* https://pusher.com

# Examples

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

```
mutation {
  createArticle(input: {
  	title: "Test Article Mutation",
    text: "Testing Article Mutation",
    userId: 1
  }) {
    success
    errors {
      code
      message
      path
    }
    article {
      title
      text
      user {
        name
      }
    }
  }
}
```

```
mutation {
  updateArticle(input: {
    id: 2
  	title: "Test Article Update Mutation",
    text: "Testing Article Update Mutation",
    userId: 2
  }) {
    success
    errors {
      code
      message
      path
    }
    article {
      title
      text
      user {
        name
      }
    }
  }
}
```

```
mutation {
  deleteArticle(input: { id: 2 }) {
    success
    errors {
      code
      message
      path
    }
  }
}
```
