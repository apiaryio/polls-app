FORMAT: 1A
HOST: http://polls.apiblueprint.org/

# Polls
Polls is a simple API allowing consumers to view polls and vote in them.

## Group Question

Resources related to questions in the API.

## Question [/questions/{question_id}]

+ Parameters
    + question_id (required, number, `1`) ... ID of the Question in form of an integer

+ Attributes
    + question: `Favourite programming language?` (string, required)
    + published_at: `2014-11-11T08:40:51.620Z` (string) - An ISO8601 date when the question was published
    + choices (array[Choice], required) - An array of Choice objects
    + url: /questions/1 (string)

### View a Questions Detail [GET]

+ Response 200 (application/json)
    + Attributes (Question)

### Delete a Question [DELETE]

+ Relation: delete
+ Response 204

## Choice [/questions/{question_id}/choices/{choice_id}]

+ Parameters
    + question_id (required, number, `1`) ... ID of the Question in form of an integer
    + choice_id (required, number, `1`) ... ID of the Choice in form of an integer

+ Attributes
    + choice: Swift (string, required)
    + votes: 0 (number, required)

### Vote on a Choice [POST]
This action allows you to vote on a question's choice.

+ Relation: vote
+ Response 201

    + Headers

            Location: /questions/1

## Questions Collection [/questions{?page}]

+ Parameters
    + page (optional, number, `1`) ... The page of questions to return
+ Attributes (array[Question])

### List All Questions [GET]

+ Relation: questions
+ Response 200 (application/json)

    + Headers

            Link: </questions?page=2>; rel="next"

    + Attributes (array[Question])

### Create a New Question [POST]

You may create your own question using this action. It takes a JSON
object containing a question and a collection of answers in the
form of choices.

+ Relation: create
+ Attributes
    + question (string, required) - The question
    + choices (array[string]) - A collection of choices.
+ Response 201 (application/json)
    + Attributes (Question)
