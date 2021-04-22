class ThesisJavierUtilities
    #include HTTParty

    def selectAllThesis
        url = 'http://127.0.0.1:8000/tracker/thesis/'
        response = RestClient.get url, {Authorization: 'Token ca393b0e830aa77ab90aa8a18fd2877f23091ad2'}
        @a_hash = JSON.parse(response.body) #hasheamos la respuesta para poder acceder
    end            

end