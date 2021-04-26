class ThesisJavierUtilities
    #include HTTParty
   
    heroku run rails console
    def selectAllThesis
        url = 'http://ec2-100-25-103-59.compute-1.amazonaws.com/tracker/thesis/'
        response = RestClient.get url, {Authorization: 'Token b99aa300d382f7491e0e6103d8cf5cd55aeecc3e'}
        @a_hash = JSON.parse(response.body) #hasheamos la respuesta para poder acceder
    end            

end