1.Clone the repo:

bash    git clone https://github.com/Varsh1009/restaurant-management-system/edit/dbms-final-project
cd NarayananSKumariS_project

2.Install Python packages:

bash   pip3 install -r requirements.txt

3.Make sure MySQL is running


Open MySQL Workbench or start MySQL server


4.Create the database:

bash   mysql -u root -p
Then inside MySQL:
sqlsource /full/path/to/database/database_dump.sql
EXIT;
Replace /full/path/to/ with actual path to the sql file.

5.Update database password:


Open app/config.py
Change DB_PASSWORD = 'your_password' to her MySQL password


6.Run the app:

bashpython3 run.py

7.Open browser:


Go to: http://localhost:5002
Login: sarah.manager / password123
