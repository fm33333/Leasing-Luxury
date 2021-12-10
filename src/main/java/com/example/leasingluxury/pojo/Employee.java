package com.example.leasingluxury.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Employee {

    private Integer eid;
    private String lastName;
    private String email;
    private Integer gender; //0：女 1：男
    private Department department;
    private Date birth;

    public Employee(Integer eid, String lastName, String email, Integer gender, Department department) {
        this.eid = eid;
        this.lastName = lastName;
        this.email = email;
        this.gender = gender;
        this.department = department;
        this.birth = new Date();
    }
}
