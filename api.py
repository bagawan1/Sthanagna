from flask import Flask, request, jsonify
from transformers import AutoTokenizer, AutoModelForTokenClassification, pipeline

app = Flask(__name__)

tokenizer = AutoTokenizer.from_pretrained("dslim/bert-large-NER")
model = AutoModelForTokenClassification.from_pretrained("dslim/bert-large-NER")
nlp = pipeline("ner", model=model, tokenizer=tokenizer)

@app.route('/ner', methods=['POST'])
def ner():
    data = request.json
    text = data['text']
    ner_results = nlp(text)
    
    # Convert all float32 scores to float
    for result in ner_results:
        result['score'] = float(result['score'])
    
    return jsonify(ner_results)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
