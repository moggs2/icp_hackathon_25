// src/RssForm.js
import React, { useState } from 'react';
import { icp_hackathon_25_backend } from 'declarations/icp_hackathon_25_backend';

function formatDate(isToday) {
    if (isToday) {
        const today = new Date();
        
        // Array of weekday names
        const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        // Array of month names
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        // Get the components of the date
        const weekday = weekdays[today.getDay()]; // Get the current weekday
        const day = String(today.getDate()).padStart(2, '0'); // Get the day and pad with zero if needed
        const month = months[today.getMonth()]; // Get the current month
        const year = today.getFullYear(); // Get the current year

        // Format the date string
        return `${weekday}, ${day} ${month} ${year}`;
    }
    return ""; // Return an empty string if isToday is false
}

function reply_parser(reply) {
    const ai_response_json = JSON.parse(reply);
    const fulltext = ai_response_json.choices;
    return fulltext[0].message.content;
}

const RssForm = () => {
  const [rssUrls, setRssUrls] = useState(['']);
  const [itemCount, setItemCount] = useState(3);
  const [isToday, setIsToday] = useState(false);
  const [filterWords, setFilterWords] = useState('');
  const [description, setDescription] = useState('');
  const [answer, setAnswer] = useState('');
  const [reply, setReply] = useState('');

  const handleUrlChange = (index, value) => {
    const newUrls = [...rssUrls];
    newUrls[index] = value;
    setRssUrls(newUrls);
  };

  const addUrl = () => {
    setRssUrls([...rssUrls, '']);
  };

  const removeUrl = (index) => {
    if (index > 0) { // Prevent removing the first URL
      const newUrls = rssUrls.filter((_, i) => i !== index);
      setRssUrls(newUrls);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // Handle form submission logic here
    const spaceSeparatedUrls = rssUrls.join(' ');
    const formattedDate = formatDate(isToday);
    console.log({
      spaceSeparatedUrls,
      itemCount,
      formattedDate,
      filterWords,
      description,
    });


    icp_hackathon_25_backend.fetch_rss_feed(spaceSeparatedUrls, formattedDate, Number(itemCount), filterWords, description).then((reply) => {
      setReply(reply_parser(reply));
    });

    console.log({reply});
    // Simulate an answer for demonstration purposes
    setAnswer(`You requested information from ${rssUrls.join(', ')} with ${itemCount} items.`);
  };


  return (
    <form onSubmit={handleSubmit} className="max-w-md mx-auto p-4 bg-white rounded shadow-md">
      <div className="mb-4">
        <label className="block text-gray-700">RSS URLs:</label>
        {rssUrls.map((url, index) => (
          <div key={index} className="flex items-center mb-2">
            <input
              type="url"
              value={url}
              onChange={(e) => handleUrlChange(index, e.target.value)}
              className="mt-1 block w-full border border-gray-300 rounded p-2"
              required
            />
            {index > 0 && (
              <button
                type="button"
                onClick={() => removeUrl(index)}
                className="ml-2 text-red-500 hover:text-red-700"
              >
                <i className="fas fa-minus-circle"></i>
              </button>
            )}
          </div>
        ))}
        <button
          type="button"
          onClick={addUrl}
          className="mt-2 text-blue-500 hover:text-blue-700"
        >
          <i className="fas fa-plus-circle"></i> Add Another URL
        </button>
      </div>

      <div className="mb-4">
        <label className="block text-gray-700">Number of Items per Feed:</label>
        <input
          type="range"
          min="1"
          max="14"
          value={itemCount}
          onChange={(e) => setItemCount(e.target.value)}
          className="w-full"
        />
        <span>{itemCount}</span>
      </div>

      <div className="mb-4">
        <label className="flex items-center">
          <input
            type="checkbox"
            checked={isToday}
            onChange={() => setIsToday(!isToday)}
            className="mr-2"
          />
          Show only today's news
        </label>
      </div>

      <div className="mb-4">
        <label className="block text-gray-700">Filter Words (space separated):</label>
        <input
          type="text"
          value={filterWords}
          onChange={(e) => setFilterWords(e.target.value)}
          className="mt-1 block w-full border border-gray-300 rounded p-2"
        />
      </div>

      <div className="mb-4">
        <label className="block text-gray-700">Describe your needs:</label>
        <textarea
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="mt-1 block w-full border border-gray-300 rounded p-2"
          rows="4"
          required
        />
      </div>

      <button
        type="submit"
        className="w-full bg-blue-500 text-white rounded p-2 hover:bg-blue-600"
      >
        Submit
      </button>

      {/* Answer Box */}
      {answer && (
        <div className="mt-4 p-4 border border-gray-300 rounded bg-gray-50">
          <h2 className="font-bold text-gray-800">Response:</h2>
          <p>{reply}</p>
        </div>
      )}
    </form>
  );
};

export default RssForm;

