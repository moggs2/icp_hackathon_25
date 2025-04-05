import { useState } from 'react';
import { icp_hackathon_25_backend } from 'declarations/icp_hackathon_25_backend';
import RssForm from './RssForm';

function App() {


  return (
    <main>
     <div className="min-h-screen flex items-center justify-center bg-gray-100">
       <div className="w-full max-w-lg p-6 bg-white rounded-lg shadow-md">
         <h1 className="text-2xl font-bold text-center mb-6">AI RSS Reader</h1>
         <RssForm />
       </div>
     </div>
    </main>


  );
}

export default App;
