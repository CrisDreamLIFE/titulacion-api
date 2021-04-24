class StudentJavierUtilities

    def selectAllStudent
        url = 'http://127.0.0.1:8000/tracker/student/'
        response = RestClient.get url, {Authorization: 'Token ca393b0e830aa77ab90aa8a18fd2877f23091ad2'}
        a_hash = JSON.parse(response.body) #hasheamos la respuesta para poder acceder
    end

    def testRequest
        url = 'http://127.0.0.1:8000/tracker/student'
        response = HTTParty.get(url, params:{id:1}, headers: {Authorization: 'Token ca393b0e830aa77ab90aa8a18fd2877f23091ad2'})
        a_hash = JSON.parse(response.body)
    end
end