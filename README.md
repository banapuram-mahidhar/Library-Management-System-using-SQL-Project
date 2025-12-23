# Library-Management-System-using-SQL-Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.
![image alt](https://github.com/banapuram-mahidhar/Library-Management-System-using-SQL-Project/blob/19730ca00df3fe30cf4eb4b24b547b4d2c1c5ec1/Library-Management-System-using-SQL-Project_img.png)


## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure


### 1. Database Setup

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select
b.category,
sum(b.rental_price),
count(*)
from issued_status as ist
join books as b 
on ist .issued_book_isbn = b.isbn
group by
b.category;

```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 1: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
select 
  isu.issued_member_id,
  mem.member_name,
  b.book_title,
  isu.issued_date,
  curdate()-isu.issued_date as over_due_days
from issued_status as isu
join
members as mem
on isu.issued_member_id = mem.member_id
join
books as b
on b.book_title = isu.issued_book_name
left join
return_status as re
on isu.issued_id = re.issued_id
where (curdate()-isu.issued_date)>30
and re.return_date is null;

```


**Task 2: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

DELIMITER $$

CREATE PROCEDURE add_return_records (
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Step 1: Insert return details into return_status table
    INSERT INTO return_status (
        return_id,
        issued_id,
        return_date,
        book_quality
    )
    VALUES (
        p_return_id,
        p_issued_id,
        CURDATE(),
        p_book_quality
    );

    -- Step 2: Retrieve ISBN and book name from issued_status table
    SELECT
        issued_book_isbn,
        issued_book_name
    INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Step 3: Update book status to 'Yes' (Available)
    UPDATE books
    SET status = 'Yes'
    WHERE isbn = v_isbn;

    -- Step 4: Display confirmation message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;

END $$

DELIMITER ;

-- TESTING FUNCTION --
select * from issued_status;

select * from books;

select * from return_status;

CALL add_return_records('RS121', 'IS135', 'Good');


```


**Task 3: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql

create table branch_report
as
select 
  b.branch_id,
  b.manager_id,
count(isu.issued_id) as number_of_book_issued,
count(rs.return_id) as number_of_book_return,
sum(bk.rental_price) as total_revenu
from issued_status as isu
join
employees as emp
on isu.issued_emp_id = emp.emp_id
join
branch as b
on emp.branch_id = b.branch_id
left join
return_status as rs
on rs.issued_id = isu.issued_id
join
books as bk
on bk.isbn = isu.issued_book_isbn
group by b.branch_id,
b.manager_id;

select * from branch_report;

```

**Task 4: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
create table active_members
as
select *
from issued_status as isu
join members as mem 
on isu.issued_member_id = mem.member_id
where issued_date >= date_sub(curdate(),interval 6 month);

select * from active_members;

```


**Task 5: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select 
  emp.emp_name,
  br.*,
count(isu.issued_id) as no_of_books_issued
from issued_status as isu
join
employees as emp
on isu.issued_emp_id = emp.emp_id
join
branch as br
on br.branch_id = emp.branch_id
group by
emp.emp_name,
br.branch_id,
br.branch_address;

```    


**Task 6: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql


delimiter $$
drop procedure if exists issue_book $$
create procedure issue_book (
	in p_issued_id varchar(10),
    in p_issued_member_id varchar(10),
    in p_issued_book_isbn varchar(20),
    in p_issued_emp_id varchar(10)
)
begin
	declare v_status varchar (10);
    -- step:1 check book avabilility --
    select status
    into v_status
    from books
    where isbn = p_issued_book_isbn ;
    -- step :2 if book is available , issue it --
    if v_status = 'yes' then
    insert into issued_status (issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
    values (p_issued_id,p_issued_member_id,curdate(),p_issued_book_isbn,p_issued_emp_id);
	
    update books
    set status = 'no'
	where isbn = p_issued_book_isbn;
    
    select concat('Book issued successfully . book ISBN : ', p_issued_book_isbn) as message;
    
    else
		select concat('sorry the requested book is currently unavailable book ISBN : ',p_issued_book_isbn) AS error_message;
	
	end if;
end $$
delimiter ;

-- testing --

select * from issued_status;
-- 978-0-06-112008-4 yes --
-- 978-0-375-41398-8 no --
call issue_book ('IS155','C108','978-0-06-112008-4','E104');
call issue_book ('IS155','C108','978-0-375-41398-8 ','E104');

```



**Task 7: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
```sql
 select * from issued_status;
 select  * from return_status;
 select 
 isu.issued_member_id	as member_id,
 count(isu.issued_id) as no_of_overduebooks,
 sum(
	greatest( 
		datediff( curdate() , issued_date )-30 ,0
		) * 0.50
  ) as total_fine
  
 From issued_status as isu
 left join return_status as rs 
 on isu.issued_id = rs.issued_id
 
 where rs.return_date is null
 and datediff( curdate() , issued_date ) > 30
 group by isu.issued_member_id;
 

```
## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.


## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

