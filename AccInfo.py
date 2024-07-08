import SocketServer
import streamlit as st
import pandas as pd 
import json
import ast

# Set page configuration options
st.set_page_config(
    layout="wide", 
)

# create connection
serv = SocketServer.SocketServer('127.0.0.1', 9090)

# empty vaules
placeholder = st.empty()

while True:

    with placeholder.container():  
        msg = serv.SendReceive("_")

        # If you receive the data as a string in JSON format
        try:
            msg_dict = json.loads(msg)
            if not isinstance(msg_dict, dict):
                print("BAD JSON!!")

            # Convert the dictionary to a DataFrame
            df = pd.DataFrame([msg_dict])

            # Ensure all columns have consistent types
            for col in df.columns:
                if df[col].apply(lambda x: isinstance(x, bool)).any():
                    df[col] = df[col].astype('bool')
                elif df[col].apply(lambda x: isinstance(x, int)).any():
                    df[col] = df[col].astype('int')
                elif df[col].apply(lambda x: isinstance(x, float)).any():
                    df[col] = df[col].astype('float')
                else:
                    df[col] = df[col].astype('str')

            # Separate account info and position info
            columns_to_remove_POS = df.filter(regex='POSITION').columns
            columns_to_remove_ACC = df.filter(regex='ACCOUNT').columns

            account_info = df.drop(columns=columns_to_remove_POS)
            
            columns = ["POSITION_MAGIC","POSITION_SYMBOL","POSITION_TYPE","POSITION_PROFIT","POSITION_TIME","POSITION_PRICE_OPEN","POSITION_VOLUME"]
            position_info = pd.DataFrame(columns=columns)
            position_data= df.drop(columns=columns_to_remove_ACC)
            position_info = pd.concat([position_info,position_data], ignore_index=True)

            # Transpose the DataFrame to display it vertically
            account_info = df.T

            # Convert all values to strings to ensure consistency
            account_info = account_info.applymap(str)

            # Convert string representations to actual lists
            for column in position_info .columns:
                position_info [column] = position_info [column].apply(ast.literal_eval)

            # Get the length of the list in the first column (assuming all lists 
            num_elements = len(position_info["POSITION_MAGIC"][0])
          
            # Create a new row for each element in the lists
            expanded_rows = []
            for i in range(num_elements):
                expanded_row = {
                    "POSITION_MAGIC": position_info["POSITION_MAGIC"][0][i],
                    "POSITION_SYMBOL": position_info["POSITION_SYMBOL"][0][i],
                    "POSITION_TYPE": position_info["POSITION_TYPE"][0][i],
                    "POSITION_PROFIT": position_info["POSITION_PROFIT"][0][i],
                    "POSITION_TIME": position_info["POSITION_TIME"][0][i],
                    "POSITION_PRICE_OPEN": position_info["POSITION_PRICE_OPEN"][0][i],
                    "POSITION_VOLUME": position_info["POSITION_VOLUME"][0][i]
                }
                expanded_rows.append(expanded_row)

            # Create a new DataFrame from the expanded rows
            expanded_position_info = pd.DataFrame(expanded_rows)

            # Display the DataFrame with Streamlit
            with placeholder.container():
                col1, col2 = st.columns([0.2, 0.8])
                with col1:
                    st.dataframe(account_info)
                with col2:
                    st.dataframe(expanded_position_info) 

        except json.JSONDecodeError:
            print("Error decoding JSON")

        