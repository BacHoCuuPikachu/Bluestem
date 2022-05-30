import logo from './logo.svg';
import './App.css';
import { useEffect, useState } from "react"

function App() {
  const [files, setFiles] = useState([])

  const fetchData = () => {
    fetch("/api/files")
      .then(response => {
        return response.text();
      })
      .then(data => {
        setFiles(data)
      })
  }

  useEffect(() => {
    fetchData()
  }, [])

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          {files}
        </p>
      </header>
    </div>
  );
}

export default App;
