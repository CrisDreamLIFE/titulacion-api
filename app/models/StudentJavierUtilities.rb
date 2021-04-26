class StudentJavierUtilities


    def selectAllStudent
        url = 'http://ec2-100-25-103-59.compute-1.amazonaws.com/tracker/student/'
        response = RestClient.get url, {Authorization: 'Token b99aa300d382f7491e0e6103d8cf5cd55aeecc3e'}
        a_hash = JSON.parse(response.body) #hasheamos la respuesta para poder acceder
    end

    def testRequest
        url = 'http://ec2-100-25-103-59.compute-1.amazonaws.com/tracker/student'
        response = HTTParty.get(url, params:{id:1}, headers: {Authorization: 'Token b99aa300d382f7491e0e6103d8cf5cd55aeecc3e'})
        a_hash = JSON.parse(response.body)
    end
end