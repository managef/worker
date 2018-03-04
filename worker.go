package main

import (
	"log"
	"net"
	"google.golang.org/grpc"
	pb "github.com/managef/models/rpc"
	job "github.com/managef/models/job"
	"google.golang.org/grpc/reflection"
	"github.com/golang/glog"
)

const (
	port = ":50051"
)

func main() {
	defer glog.Flush()
	lis, err := net.Listen("tcp", port)

	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	jobServer := job.Server{}
	pb.RegisterJobServer(s,&jobServer)
	// Register reflection service on gRPC server.
	reflection.Register(s)
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}